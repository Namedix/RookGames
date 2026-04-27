import { NextResponse, type NextRequest } from "next/server";
import { z } from "zod";
import { cacheGet, cacheKeys, cacheSet, TTL } from "@/lib/cache";
import { fetchThings, isBggLive, searchIds } from "@/lib/bgg";
import { searchCatalog } from "@/lib/catalog";
import type { GameDTO } from "@/lib/types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const querySchema = z.object({
  q: z.string().trim().max(120).default(""),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

function normalize(q: string): string {
  return q.trim().toLowerCase().replace(/\s+/g, " ");
}

function jsonResults(
  games: GameDTO[],
  source: "bgg" | "catalog" | "empty"
): NextResponse {
  return NextResponse.json(games, {
    headers: {
      "Cache-Control":
        source === "bgg"
          ? "public, s-maxage=604800, stale-while-revalidate=86400"
          : "public, s-maxage=86400, stale-while-revalidate=3600",
      "X-Rook-Source": source,
    },
  });
}

export async function GET(request: NextRequest) {
  const params = querySchema.safeParse({
    q: request.nextUrl.searchParams.get("q") ?? "",
    limit: request.nextUrl.searchParams.get("limit") ?? undefined,
  });
  if (!params.success) {
    return NextResponse.json({ error: "Invalid query" }, { status: 400 });
  }
  const refresh = request.nextUrl.searchParams.get("refresh") === "1";
  const q = normalize(params.data.q);
  const limit = params.data.limit;

  if (q.length < 2) {
    return jsonResults([], "empty");
  }

  if (!isBggLive()) {
    return jsonResults(searchCatalog(q, limit), "catalog");
  }

  try {
    const searchKey = cacheKeys.search(q, limit);

    let ids: number[] | null = null;
    if (!refresh) {
      ids = await cacheGet<number[]>(searchKey);
    }
    if (!ids) {
      ids = await searchIds(q, limit);
      await cacheSet(searchKey, ids, TTL.search);
    }

    if (ids.length === 0) {
      return jsonResults([], "bgg");
    }

    const cachedGames = (await Promise.all(
      ids.map((id) => cacheGet<GameDTO>(cacheKeys.thing(id)))
    )) as (GameDTO | null)[];

    const missingIds = ids.filter((_, i) => cachedGames[i] === null);

    let fetched: GameDTO[] = [];
    if (missingIds.length > 0) {
      fetched = await fetchThings(missingIds);
      await Promise.all(
        fetched.map((g) => cacheSet(cacheKeys.thing(g.id), g, TTL.thing))
      );
    }

    const fetchedById = new Map(fetched.map((g) => [g.id, g] as const));
    const games: GameDTO[] = ids
      .map((id, i) => cachedGames[i] ?? fetchedById.get(id) ?? null)
      .filter((g): g is GameDTO => g !== null);

    return jsonResults(games, "bgg");
  } catch (error) {
    console.warn("[search] BGG failed, falling back to catalog:", error);
    const fallback = searchCatalog(q, limit);
    if (fallback.length > 0) {
      return jsonResults(fallback, "catalog");
    }
    const message = error instanceof Error ? error.message : "Upstream failure";
    return NextResponse.json({ error: message }, { status: 502 });
  }
}
