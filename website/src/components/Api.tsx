const ENDPOINTS = [
  {
    method: 'GET',
    path: '/api/v1/stops?search=',
    purpose: 'Trigram stop search, paginated',
  },
  {
    method: 'GET',
    path: '/api/v1/stops/nearby',
    purpose: 'Stops around a point, KNN-ordered with distance',
  },
  {
    method: 'GET',
    path: '/api/v1/stops/{id}/departures',
    purpose: 'Upcoming departures — calendars & after-midnight handled',
  },
  {
    method: 'GET',
    path: '/api/v1/routes/{id}/shape',
    purpose: 'Route polyline as GeoJSON',
  },
  {
    method: 'GET',
    path: '/api/v1/planner',
    purpose: 'CSA journey plan between stops or coordinates',
  },
  {
    method: 'GET',
    path: '/api/v1/live/vehicles',
    purpose: 'Latest simulated vehicle positions',
  },
  {
    method: 'WS',
    path: '/ws/realtime',
    purpose: 'Snapshot on connect, then live vehicle updates',
  },
]

export function Api() {
  return (
    <section id="api" className="bg-slate-50 py-20 sm:py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="max-w-2xl">
          <p className="text-sm font-semibold tracking-wide text-blue-600 uppercase">
            API
          </p>
          <h2 className="font-display mt-2 text-3xl font-bold tracking-tight sm:text-4xl">
            A small, honest REST API
          </h2>
          <p className="mt-4 text-lg leading-relaxed text-slate-600">
            Everything the app shows comes through these endpoints — with
            interactive OpenAPI docs at{' '}
            <code className="rounded bg-slate-200/70 px-1.5 py-0.5 font-mono text-base">
              /docs
            </code>{' '}
            once the backend is running.
          </p>
        </div>

        <div className="mt-10 overflow-x-auto rounded-2xl border border-slate-200 bg-white">
          <table className="w-full min-w-[560px] text-left text-sm">
            <thead>
              <tr className="border-b border-slate-200 text-xs tracking-wide text-slate-500 uppercase">
                <th scope="col" className="px-5 py-3.5 font-semibold">
                  Endpoint
                </th>
                <th scope="col" className="px-5 py-3.5 font-semibold">
                  Purpose
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {ENDPOINTS.map(({ method, path, purpose }) => (
                <tr key={path} className="hover:bg-slate-50">
                  <td className="px-5 py-3.5 whitespace-nowrap">
                    <span
                      className={`mr-2.5 inline-block w-10 rounded-md px-1.5 py-0.5 text-center font-mono text-xs font-semibold ${
                        method === 'WS'
                          ? 'bg-violet-100 text-violet-700'
                          : 'bg-emerald-100 text-emerald-700'
                      }`}
                    >
                      {method}
                    </span>
                    <code className="font-mono text-[13px] text-slate-800">
                      {path}
                    </code>
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{purpose}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  )
}
