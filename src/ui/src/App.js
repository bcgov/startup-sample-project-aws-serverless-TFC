import React from "react";
import "./App.css";
import GreetingSelector from "./GreetingSelector";
import GreetingList from "./GreetingList";

function App() {
  return (
    <div className="App">
      <h1>Select a greeting</h1>
      <GreetingSelector />
      <GreetingList />
    </div>
  );
}

export default App;
