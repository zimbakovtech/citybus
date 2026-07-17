import {
  ArrowDown,
  Check,
  Database,
  Server,
  Smartphone,
  type LucideIcon,
} from 'lucide-react'

type Layer = {
  icon: LucideIcon
  name: string
  role: string
  description: string
  chips: string[]
}

const LAYERS: Layer[] = [
  {
    icon: Smartphone,
    name: 'Flutter app',
    role: 'Presentation',
    description:
      'Feature-first mobile app talking to the backend over REST (/api/v1) and a realtime WebSocket (/ws/realtime).',
    chips: ['Flutter 3', 'Riverpod 3', 'GoRouter', 'Dio', 'freezed', 'flutter_map'],
  },
  {
    icon: Server,
    name: 'FastAPI backend',
    role: 'API & domain logic',
    description:
      'Endpoints → services → repositories. Hosts the CSA journey planner, the GTFS importer and the vehicle-position simulation.',
    chips: ['FastAPI', 'SQLAlchemy 2 (async)', 'asyncpg', 'Alembic', 'Pydantic v2'],
  },
  {
    icon: Database,
    name: 'PostgreSQL 16 + PostGIS 3.5',
    role: 'The core deliverable',
    description:
      'A relational GTFS schema with spatial geometries, trigram text search and indexes tuned for the hot schedule lookups.',
    chips: ['GTFS schema', 'GiST + GIN indexes', 'pg_trgm', 'Docker'],
  },
]

const MODEL_HIGHLIGHTS = [
  {
    title: 'stop_times is the grain',
    text: 'One row per (trip, stop) scheduled event — the finest-grained table everything else hangs off.',
  },
  {
    title: 'interval, not time',
    text: 'GTFS times exceed 24:00:00 for after-midnight service; a time column would corrupt them. The seed feed proves it with a 24:29 arrival.',
  },
  {
    title: 'Surrogate keys everywhere',
    text: 'bigint IDENTITY primary keys with the GTFS string ids kept as UNIQUE natural keys — compact joins, feed-replacement safety.',
  },
  {
    title: 'Derived shape geometry',
    text: 'Raw shape points are assembled into one LineString per shape at import, so a map polyline is a single-row fetch.',
  },
  {
    title: 'services normalization',
    text: 'GTFS service_id becomes its own entity referenced by calendar, calendar_dates and trips — exception-only feeds just work.',
  },
  {
    title: 'Indexes for the hot paths',
    text: 'GiST on geometries for KNN, trigram GIN on searchable names, B-tree composites on (stop_id, departure_time) and (trip_id, stop_sequence).',
  },
]

export function Architecture() {
  return (
    <section id="architecture" className="bg-white py-20 sm:py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold tracking-wide text-blue-600 uppercase">
            Architecture
          </p>
          <h2 className="font-display mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
            Three layers, one data model
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-slate-600">
            The database is the star of the show — the backend and app exist to
            prove the data model works end to end, from a GTFS feed on disk to
            a live map on a phone.
          </p>
        </div>

        <ol className="mt-12 space-y-3">
          {LAYERS.map(({ icon: Icon, name, role, description, chips }, i) => (
            <li key={name}>
              {i > 0 && (
                <div
                  className="mb-3 flex justify-center text-slate-300"
                  aria-hidden="true"
                >
                  <ArrowDown className="size-5" />
                </div>
              )}
              <div className="flex flex-col gap-4 rounded-2xl border border-slate-200 p-6 sm:flex-row sm:items-start sm:gap-6">
                <span className="inline-flex size-12 shrink-0 items-center justify-center rounded-xl bg-blue-600/10 text-blue-600">
                  <Icon className="size-6" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                    <h3 className="font-display text-lg font-semibold">
                      {name}
                    </h3>
                    <span className="text-xs font-medium tracking-wide text-blue-600 uppercase">
                      {role}
                    </span>
                  </div>
                  <p className="mt-1.5 text-sm leading-relaxed text-slate-600">
                    {description}
                  </p>
                  <ul className="mt-3 flex flex-wrap gap-1.5">
                    {chips.map((chip) => (
                      <li
                        key={chip}
                        className="rounded-md border border-slate-200 bg-slate-50 px-2 py-1 font-mono text-xs text-slate-600"
                      >
                        {chip}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </li>
          ))}
        </ol>

        <div className="mt-16 rounded-2xl bg-slate-50 p-6 sm:p-10">
          <h3 className="font-display text-xl font-bold tracking-tight sm:text-2xl">
            Data-model decisions worth stealing
          </h3>
          <ul className="mt-8 grid gap-x-10 gap-y-6 sm:grid-cols-2">
            {MODEL_HIGHLIGHTS.map(({ title, text }) => (
              <li key={title} className="flex gap-3">
                <span className="mt-0.5 inline-flex size-5 shrink-0 items-center justify-center rounded-full bg-blue-600 text-white">
                  <Check className="size-3" aria-hidden="true" strokeWidth={3} />
                </span>
                <div>
                  <h4 className="text-sm font-semibold text-slate-900">
                    {title}
                  </h4>
                  <p className="mt-1 text-sm leading-relaxed text-slate-600">
                    {text}
                  </p>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  )
}
