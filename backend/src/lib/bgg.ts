import { XMLParser } from "fast-xml-parser";
import type { GameDTO } from "./types";

const BASE_URL = process.env.BGG_BASE_URL ?? "https://boardgamegeek.com/xmlapi2";
const USER_AGENT = "rookgames-backend/1.0 (+https://github.com/rookgames)";

const xmlParser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: "",
  textNodeName: "_text",
  parseAttributeValue: false,
  isArray: (name) => name === "item" || name === "name" || name === "link",
});

type RawAttr = { value?: string; id?: string; type?: string };
type RawName = RawAttr & { _text?: string };
type RawLink = { type?: string; value?: string };

interface RawItem {
  id?: string;
  type?: string;
  thumbnail?: string;
  image?: string;
  name?: RawName[];
  description?: string;
  yearpublished?: RawAttr;
  minplayers?: RawAttr;
  maxplayers?: RawAttr;
  minplaytime?: RawAttr;
  maxplaytime?: RawAttr;
  playingtime?: RawAttr;
  link?: RawLink[];
  statistics?: {
    ratings?: {
      averageweight?: RawAttr;
    };
  };
}

interface RawSearchItem {
  id?: string;
  type?: string;
  name?: RawName[];
  yearpublished?: RawAttr;
}

class BGGError extends Error {
  constructor(message: string, readonly status = 502) {
    super(message);
    this.name = "BGGError";
  }
}

export class BGGNotFound extends BGGError {
  constructor(message = "Not found") {
    super(message, 404);
    this.name = "BGGNotFound";
  }
}

async function fetchXml(path: string, search: URLSearchParams): Promise<string> {
  const url = `${BASE_URL}${path}?${search.toString()}`;
  const response = await fetch(url, {
    headers: { "User-Agent": USER_AGENT, Accept: "application/xml" },
    cache: "no-store",
  });
  if (response.status === 202) {
    throw new BGGError("BGG queued the request, retry later.", 503);
  }
  if (!response.ok) {
    throw new BGGError(`BGG ${path} failed: ${response.status}`, 502);
  }
  return await response.text();
}

function pickPrimaryName(names: RawName[] | undefined): string {
  if (!names || names.length === 0) return "";
  const primary = names.find((n) => n.type === "primary") ?? names[0];
  return primary?.value ?? primary?._text ?? "";
}

function toInt(raw: string | undefined, fallback: number): number {
  if (raw == null) return fallback;
  const n = Number.parseInt(raw, 10);
  return Number.isFinite(n) ? n : fallback;
}

function toFloat(raw: string | undefined, fallback: number): number {
  if (raw == null) return fallback;
  const n = Number.parseFloat(raw);
  return Number.isFinite(n) ? n : fallback;
}

function decodeEntities(input: string): string {
  return input
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&#10;/g, "\n")
    .replace(/&#13;/g, "\r")
    .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)));
}

function cleanDescription(input: string | undefined): string {
  if (!input) return "";
  return decodeEntities(input).replace(/\s+/g, " ").trim();
}

function pickLinks(item: RawItem, type: string): string[] {
  return (item.link ?? [])
    .filter((l) => l.type === type && typeof l.value === "string")
    .map((l) => l.value as string);
}

function itemToDTO(item: RawItem): GameDTO {
  const id = toInt(item.id, 0);
  const minPlayers = toInt(item.minplayers?.value, 1);
  const maxPlayers = toInt(item.maxplayers?.value, minPlayers);
  const minPlaytime = toInt(item.minplaytime?.value, 0);
  const playtime = toInt(item.playingtime?.value, minPlaytime);
  const maxPlaytime = toInt(item.maxplaytime?.value, playtime);
  return {
    id,
    name: pickPrimaryName(item.name),
    yearPublished: item.yearpublished?.value
      ? toInt(item.yearpublished.value, 0) || null
      : null,
    thumbnailURL: item.thumbnail ?? null,
    imageURL: item.image ?? null,
    summary: cleanDescription(item.description),
    minPlayers,
    maxPlayers,
    minPlaytimeMinutes: minPlaytime || playtime,
    maxPlaytimeMinutes: maxPlaytime || playtime,
    complexity: toFloat(item.statistics?.ratings?.averageweight?.value, 0),
    categories: pickLinks(item, "boardgamecategory"),
    mechanics: pickLinks(item, "boardgamemechanic"),
    designers: pickLinks(item, "boardgamedesigner"),
  };
}

interface ParsedItems {
  items?: { item?: RawItem[] };
}

interface ParsedSearch {
  items?: { item?: RawSearchItem[] };
}

export async function fetchThings(ids: readonly number[]): Promise<GameDTO[]> {
  if (ids.length === 0) return [];
  const params = new URLSearchParams({
    id: ids.join(","),
    stats: "1",
  });
  const xml = await fetchXml("/thing", params);
  const parsed = xmlParser.parse(xml) as ParsedItems;
  const rawItems = parsed.items?.item ?? [];
  return rawItems.map(itemToDTO).filter((g) => g.id !== 0 && g.name !== "");
}

export async function fetchThing(id: number): Promise<GameDTO> {
  const games = await fetchThings([id]);
  const found = games[0];
  if (!found) throw new BGGNotFound(`Game ${id} not found on BGG.`);
  return found;
}

export async function searchIds(
  query: string,
  limit: number
): Promise<number[]> {
  const params = new URLSearchParams({
    type: "boardgame,boardgameexpansion",
    query,
  });
  const xml = await fetchXml("/search", params);
  const parsed = xmlParser.parse(xml) as ParsedSearch;
  const rawItems = parsed.items?.item ?? [];
  const ids: number[] = [];
  for (const it of rawItems) {
    const id = toInt(it.id, 0);
    if (id !== 0 && !ids.includes(id)) ids.push(id);
    if (ids.length >= limit) break;
  }
  return ids;
}

export { BGGError };
