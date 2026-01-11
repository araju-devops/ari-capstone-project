import React, { useState } from "react";
import "./App.css";

function App() {
  const [selectedA, setSelectedA] = useState(null);
  const [selectedB, setSelectedB] = useState(null);
  const [response, setResponse] = useState(null);
  const [loadingA, setLoadingA] = useState(false);
  const [loadingB, setLoadingB] = useState(false);

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || '';

  const getApiUrl = (target) => {
    // Returns something like "https://my-apim-gateway.azure-api.net/api/A:/"
    // APIM expects uppercase paths with colon and trailing slash: /api/A:/ and /api/B:/
    return `${API_BASE_URL}/api/${target.toUpperCase()}:/`;
  };

  async function uploadTo(target) {
    if (!selectedA && target === 'a') {
      alert('Please select a file first');
      return;
    }
    if (!selectedB && target === 'b') {
      alert('Please select a file first');
      return;
    }

    const form = new FormData();
    if (target === "a") {
      form.append("image", selectedA);
      setLoadingA(true);
    }
    if (target === "b") {
      form.append("image", selectedB);
      setLoadingB(true);
    }

    try {
      const apiUrl = getApiUrl(target);
      console.log(`Uploading to: ${apiUrl}`);

      const res = await fetch(apiUrl, { method: "POST", body: form });

      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }

      const data = await res.json();
      setResponse({ success: true, target: target.toUpperCase(), data });
    } catch (error) {
      console.error('Upload error:', error);
      setResponse({
        success: false,
        target: target.toUpperCase(),
        error: error.message,
        apiUrl: getApiUrl(target)
      });
    } finally {
      if (target === 'a') setLoadingA(false);
      if (target === 'b') setLoadingB(false);
    }
  }

  return (
    <div className="page">
      <h1>Multi-Backend Image Upload (Kubernetes)</h1>

      <div className="grid">
        <div className="card">
          <h2>Backend A</h2>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => setSelectedA(e.target.files[0])}
            disabled={loadingA}
          />
          <button onClick={() => uploadTo("a")} disabled={loadingA}>
            {loadingA ? "Uploading..." : "Upload to A"}
          </button>
          {selectedA && <p className="file-info">Selected: {selectedA.name}</p>}
        </div>

        <div className="card">
          <h2>Backend B</h2>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => setSelectedB(e.target.files[0])}
            disabled={loadingB}
          />
          <button onClick={() => uploadTo("b")} disabled={loadingB}>
            {loadingB ? "Uploading..." : "Upload to B"}
          </button>
          {selectedB && <p className="file-info">Selected: {selectedB.name}</p>}
        </div>
      </div>

      <div className="response-section">
        <h2>Response:</h2>
        <pre>{response ? JSON.stringify(response, null, 2) : "No responses yet"}</pre>
      </div>
    </div>
  );
}

export default App;
