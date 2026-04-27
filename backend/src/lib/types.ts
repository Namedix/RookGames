/**
 * JSON shape returned to the iOS client. Field names and optionality
 * match `Rook/Sources/Models/Game.swift` exactly so the Swift `Game`
 * struct decodes 1:1 with the default `JSONDecoder`.
 *
 * `addedAt` is intentionally not part of this DTO — it is a local-only
 * field assigned when the user adds the game to their library.
 */
export type GameDTO = {
  id: number;
  name: string;
  yearPublished: number | null;
  thumbnailURL: string | null;
  imageURL: string | null;
  summary: string;
  minPlayers: number;
  maxPlayers: number;
  minPlaytimeMinutes: number;
  maxPlaytimeMinutes: number;
  complexity: number;
  categories: string[];
  mechanics: string[];
  designers: string[];
};
