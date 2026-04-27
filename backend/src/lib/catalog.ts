import { seedCatalog } from "./seedCatalog";
import type { GameDTO } from "./types";

/**
 * Indexes the seed catalog for fast lookup + simple ranked substring
 * search. Built once per cold start. Replace this whole module with a
 * proper datastore (Postgres, SQLite, search index) when the catalog
 * outgrows ~1k entries.
 */
const byId: ReadonlyMap<number, GameDTO> = new Map(
  seedCatalog.map((g) => [g.id, g] as const)
);

interface IndexEntry {
  game: GameDTO;
  haystack: string;
  nameLower: string;
}

const index: readonly IndexEntry[] = seedCatalog.map((game) => ({
  game,
  nameLower: game.name.toLowerCase(),
  haystack: [
    game.name,
    ...game.designers,
    ...game.categories,
    ...game.mechanics,
  ]
    .join(" ")
    .toLowerCase(),
}));

export function lookupCatalog(id: number): GameDTO | null {
  return byId.get(id) ?? null;
}

/**
 * Ranked substring search. Prefers prefix-of-name matches, then
 * substring-of-name, then matches anywhere in the haystack
 * (designers / categories / mechanics).
 */
export function searchCatalog(query: string, limit: number): GameDTO[] {
  const needle = query.trim().toLowerCase();
  if (needle.length === 0) return [];

  type Scored = { game: GameDTO; score: number };
  const scored: Scored[] = [];
  for (const entry of index) {
    let score = 0;
    if (entry.nameLower === needle) score = 100;
    else if (entry.nameLower.startsWith(needle)) score = 50;
    else if (entry.nameLower.includes(needle)) score = 25;
    else if (entry.haystack.includes(needle)) score = 10;
    if (score > 0) scored.push({ game: entry.game, score });
  }
  scored.sort((a, b) => b.score - a.score || a.game.name.localeCompare(b.game.name));
  return scored.slice(0, limit).map((s) => s.game);
}

export function catalogSize(): number {
  return seedCatalog.length;
}
