import { NextResponse, type NextRequest } from "next/server";
import { z } from "zod";
import { cacheKeys, cached, TTL } from "@/lib/cache";
import { BGGNotFound, fetchThing } from "@/lib/bgg";
import type { GameDTO } from "@/lib/types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const idSchema = z.coerce.number().int().positive();

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

  try {
    const game = await cached<GameDTO>(
      cacheKeys.thing(id),
      TTL.thing,
      () => fetchThing(id),
      { refresh }
    );
    return NextResponse.json(game, {
      headers: {
        "Cache-Control":
          "public, s-maxage=2592000, stale-while-revalidate=86400",
      },
    });
  } catch (error) {
    if (error instanceof BGGNotFound) {
      return NextResponse.json({ error: error.message }, { status: 404 });
    }
    const message = error instanceof Error ? error.message : "Upstream failure";
    return NextResponse.json({ error: message }, { status: 502 });
  }
}
