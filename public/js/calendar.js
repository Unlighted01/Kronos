document.addEventListener("DOMContentLoaded", function () {
    const monthNames = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ];
    const daysContainer = document.getElementById("days");
    const monthYear = document.getElementById("month-year");
    const prevBtn = document.getElementById("prev");
    const nextBtn = document.getElementById("next-btn");

    let currentDate = new Date();
    let today = new Date();

    function getMoonPhaseSymbol(date) {
        const refDate = new Date(2000, 0, 6);
        const diffTime = date.getTime() - refDate.getTime();
        const diffDays = diffTime / (1000 * 60 * 60 * 24);
        const cycle = 29.530588853;
        const age = ((diffDays % cycle) + cycle) % cycle;

        if (age < 1.845) return "🌑"; // New Moon
        if (age < 5.537) return "🌒"; // Waxing Crescent
        if (age < 9.228) return "🌓"; // First Quarter
        if (age < 12.92) return "🌔"; // Waxing Gibbous
        if (age < 16.611) return "🌕"; // Full Moon
        if (age < 20.303) return "🌖"; // Waning Gibbous
        if (age < 23.994) return "🌗"; // Last Quarter
        if (age < 27.686) return "🌘"; // Waning Crescent
        return "🌑";
    }

    function renderCalendar() {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();

        // Find the weekday index of the first day of the month (0 = Sunday, 6 = Saturday)
        const firstDayIndex = new Date(year, month, 1).getDay();
        const lastday = new Date(year, month + 1, 0).getDate();

        monthYear.textContent = `${monthNames[month]} ${year}`;

        daysContainer.innerHTML = "";

        // Add empty spaces for the days of the previous month with moon phases
        for (let i = 0; i < firstDayIndex; i++) {
            const emptyDiv = document.createElement("div");
            emptyDiv.classList.add("empty");
            const prevDate = new Date(year, month, 1 - (firstDayIndex - i));
            emptyDiv.textContent = getMoonPhaseSymbol(prevDate);
            daysContainer.appendChild(emptyDiv);
        }

        for (let i = 1; i <= lastday; i++) {
            const dayDiv = document.createElement("div");
            dayDiv.textContent = i;
            if (
                i === today.getDate() &&
                month === today.getMonth() &&
                year === today.getFullYear()
            ) {
                dayDiv.classList.add("today");
            }
            daysContainer.appendChild(dayDiv);
        }

        // Add empty spaces to fill the last row of the calendar with moon phases
        const totalCells = firstDayIndex + lastday;
        const remainingCells = (7 - (totalCells % 7)) % 7;
        for (let j = 0; j < remainingCells; j++) {
            const emptyDiv = document.createElement("div");
            emptyDiv.classList.add("empty");
            const nextDate = new Date(year, month + 1, j + 1);
            emptyDiv.textContent = getMoonPhaseSymbol(nextDate);
            daysContainer.appendChild(emptyDiv);
        }
    }

    prevBtn.addEventListener("click", () => {
        currentDate.setMonth(currentDate.getMonth() - 1);
        renderCalendar();
    });

    nextBtn.addEventListener("click", () => {
        currentDate.setMonth(currentDate.getMonth() + 1);
        renderCalendar();
    });

    renderCalendar();
});
