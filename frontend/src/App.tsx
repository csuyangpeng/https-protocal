import { useEffect, useState } from 'react'
import './App.css'

type HelloResponse = {
  message: string
}

function App() {
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/hello')
      .then((res) => {
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`)
        }
        return res.json() as Promise<HelloResponse>
      })
      .then((data) => setMessage(data.message))
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  return (
    <main className="app">
      <h1>React + Go HTTPS Demo</h1>
      <p className="subtitle">Frontend served over HTTPS, calling Go API over HTTPS</p>

      <section className="card">
        <h2>API Response</h2>
        {loading && <p className="status">Loading...</p>}
        {error && <p className="status error">Error: {error}</p>}
        {message && <p className="message">{message}</p>}
      </section>

      <ul className="endpoints">
        <li>Frontend: <code>https://localhost:5173</code></li>
        <li>Backend: <code>https://localhost:8443/api/hello</code></li>
      </ul>
    </main>
  )
}

export default App
