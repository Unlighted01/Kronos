import React from "react";
import { WidgetView } from "./components/widget/WidgetView";
import { DashboardView } from "./components/dashboard/DashboardView";

export const App: React.FC = () => {
    const [hash, setHash] = React.useState<string>(window.location.hash);

    React.useEffect(() => {
        const handleHashChange = () => setHash(window.location.hash);
        window.addEventListener("hashchange", handleHashChange);
        return () => window.removeEventListener("hashchange", handleHashChange);
    }, []);

    if (hash === "#widget") {
        return <WidgetView />;
    }

    return <DashboardView />;
};

export default App;
