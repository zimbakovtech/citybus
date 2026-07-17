import {
  Clock,
  MapPin,
  PackageCheck,
  Radio,
  Route,
  Search,
  type LucideIcon,
} from 'lucide-react'

type Feature = {
  icon: LucideIcon
  title: string
  description: string
}

const FEATURES: Feature[] = [
  {
    icon: Search,
    title: 'Fuzzy stop & route search',
    description:
      'Typo-tolerant text search over stop and route names, backed by pg_trgm trigram GIN indexes in the database.',
  },
  {
    icon: MapPin,
    title: 'Nearby stops',
    description:
      'Stops around your location, distance-ordered with PostGIS KNN queries on GiST-indexed geometries.',
  },
  {
    icon: Clock,
    title: 'Departure boards',
    description:
      'Upcoming departures per stop, correctly resolving service calendars, holiday exceptions and after-midnight trips.',
  },
  {
    icon: Route,
    title: 'Journey planner',
    description:
      'Earliest-arrival journeys with transfers, computed by the Connection Scan Algorithm — among equally fast options, fewer transfers win.',
  },
  {
    icon: Radio,
    title: 'Live vehicle map',
    description:
      'Simulated vehicle positions interpolated from the schedule, broadcast to the app over WebSockets roughly every 2 seconds.',
  },
  {
    icon: PackageCheck,
    title: 'Fully offline',
    description:
      'A synthetic but realistic GTFS feed for Skopje ships with the repo — weekday and weekend services, a holiday exception, even a night trip.',
  },
]

export function Features() {
  return (
    <section id="features" className="bg-white py-20 sm:py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold tracking-wide text-blue-600 uppercase">
            Features
          </p>
          <h2 className="font-display mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
            Everything a transit rider needs
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-slate-600">
            Each feature exists to prove a part of the data model — spatial
            queries, schedule resolution, graph-based routing and realtime
            updates, all driven by the same GTFS schema.
          </p>
        </div>

        <ul className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map(({ icon: Icon, title, description }) => (
            <li
              key={title}
              className="rounded-2xl border border-slate-200 bg-slate-50/60 p-6 transition-colors hover:border-blue-200 hover:bg-blue-50/40"
            >
              <span className="inline-flex size-11 items-center justify-center rounded-xl bg-blue-600/10 text-blue-600">
                <Icon className="size-5" aria-hidden="true" />
              </span>
              <h3 className="font-display mt-4 text-lg font-semibold">
                {title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-slate-600">
                {description}
              </p>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )
}
