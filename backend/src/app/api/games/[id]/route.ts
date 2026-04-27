import { NextResponse, type NextRequest } from "next/server";
import { z } from "zod";
import { cacheKeys, cached, TTL } from "@/lib/cache";
import { BGGNotFound, fetchThing, isBggLive } from "@/lib/bgg";
import { lookupCatalog } from "@/lib/catalog";
import type { GameDTO } from "@/lib/types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const idSchema = z.coerce.number().int().positive();

function jsonWithSource(
  game: GameDTO,
  source: "bgg" | "catalog"
): NextResponse {
  return NextResponse.json(game, {
    headers: {
      "Cache-Control":
        source === "bgg"
          ? "public, s-maxage=2592000, stale-while-revalidate=86400"
          : "public, s-maxage=86400, stale-while-revalidate=3600",
      "X-Rook-Source": source,
    },
  });
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id: rawId } = await params;
  const parsed = idSchema.safeParse(rawId);
  if (!parsed.success) {
    return NextResponse.json({ error: "Invalid id" }, { status: 400 });
  }
  const id = parsed.data;
  const refresh = request.nextUrl.searchParams.get("refresh") === "1";

  if (isBggLive()) {
    try {
      const game = await cached<GameDTO>(
        cacheKeys.thing(id),
        TTL.thing,
        () => fetchThing(id),
        { refresh }
      );
      return jsonWithSource(game, "bgg");
    } catch (error) {
      if (error instanceof BGGNotFound) {
        const seeded = lookupCatalog(id);
        if (seeded) return jsonWithSource(seeded, "catalog");
        return NextResponse.json({ error: error.message }, { status: 404 });
      }
      console.warn(`[games/${id}] BGG failed, falling back to catalog:`, error);
      const seeded = lookupCatalog(id);
      if (seeded) return jsonWithSource(seeded, "catalog");
      const message = error instanceof Error ? error.message : "Upstream failure";
      return NextResponse.json({ error: message }, { status: 502 });
    }
  }

  const seeded = lookupCatalog(id);
  if (seeded) return jsonWithSource(seeded, "catalog");
  return NextResponse.json(
    {
      error:
        "Game not in seed catalog. Set BGG_API_TOKEN to enable live BoardGameGeek lookups.",
    },
    { status: 404 }
  );
}
