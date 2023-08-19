import React from "react";
import "./App.css";
import GreetingProvider from "./GreetingProvider";
import GreetingList from "./GreetingList";
import GreetingSelector from "./GreetingSelector";

function App() {
  return (
    <div className="App">
      <h1>Public Cloud Sample Application</h1>
      <GreetingProvider>
        <GreetingSelector />
        <GreetingList />
      </GreetingProvider>
    </div>
  );
}

export default App;
