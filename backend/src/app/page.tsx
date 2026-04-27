export default function HomePage() {
  return (
    <main style={{ fontFamily: "system-ui, sans-serif", padding: 32 }}>
      <h1>Rook Backend</h1>
      <p>BoardGameGeek proxy + cache for the Rook iOS app.</p>
      <ul>
        <li>
          <code>GET /api/games/:id</code> — BGG thing lookup
        </li>
        <li>
          <code>GET /api/search?q=...&amp;limit=20</code> — BGG search
        </li>
        <li>
          <code>GET /api/health</code> — liveness probe
        </li>
      </ul>
    </main>
  );
}
