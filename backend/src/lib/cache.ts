import { Redis } from "@upstash/redis";

/**
 * Time-to-live constants for cache entries. BGG metadata for a given
 * `objectid` is effectively immutable, but we still expire to give
 * occasional edits (e.g. corrected complexity ratings) a path back in.
 */
export const TTL = {
  /** Individual `xmlapi2/thing` payload — 30 days. */
  thing: 60 * 60 * 24 * 30,
  /** Search-result id list — 7 days. */
  search: 60 * 60 * 24 * 7,
} as const;

let redisSingleton: Redis | null = null;
let warnedAboutMissingConfig = false;

/**
 * Returns the Upstash client, or `null` if the integration hasn't
 * been wired up yet. Callers treat `null` as a permanent cache miss
 * so the backend stays useful (just slower) while Upstash is being
 * provisioned.
 */
function getRedis(): Redis | null {
  if (redisSingleton) return redisSingleton;
  const url = process.env.KV_REST_API_URL;
  const token = process.env.KV_REST_API_TOKEN;
  if (!url || !token) {
    if (!warnedAboutMissingConfig) {
      warnedAboutMissingConfig = true;
      console.warn(
        "[cache] Upstash not configured (KV_REST_API_URL / KV_REST_API_TOKEN missing). Running in pass-through mode — every request hits BGG."
      );
    }
    return null;
  }
  redisSingleton = new Redis({ url, token });
  return redisSingleton;
}

export async function cacheGet<T>(key: string): Promise<T | null> {
  const redis = getRedis();
  if (!redis) return null;
  try {
    const value = await redis.get<T>(key);
    return value ?? null;
  } catch (error) {
    console.warn(`[cache] get(${key}) failed, treating as miss:`, error);
    return null;
  }
}

export async function cacheSet<T>(
  key: string,
  value: T,
  ttlSeconds: number
): Promise<void> {
  const redis = getRedis();
  if (!redis) return;
  try {
    await redis.set(key, value, { ex: ttlSeconds });
  } catch (error) {
    console.warn(`[cache] set(${key}) failed, dropping write:`, error);
  }
}

/**
 * Read-through cache helper. If `refresh` is true the loader is
 * invoked unconditionally, but the result is still written through.
 */
export async function cached<T>(
  key: string,
  ttlSeconds: number,
  loader: () => Promise<T>,
  options: { refresh?: boolean } = {}
): Promise<T> {
  if (!options.refresh) {
    const hit = await cacheGet<T>(key);
    if (hit !== null) return hit;
  }
  const fresh = await loader();
  await cacheSet(key, fresh, ttlSeconds);
  return fresh;
}

export const cacheKeys = {
  thing: (id: number) => `bgg:thing:${id}`,
  search: (q: string, limit: number) => `bgg:search:${q}:${limit}`,
} as const;
