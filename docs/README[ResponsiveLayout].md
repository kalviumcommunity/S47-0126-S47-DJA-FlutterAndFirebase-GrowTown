# Responsive Layout — GrowTown

## Project Title and short explanation

This screen demonstrates responsive layout using Flutter's core layout widgets: `Container`, `Row`, `Column`, `Expanded`, and `MediaQuery`. The UI adapts so small screens show customer panels stacked vertically while large screens show them side-by-side in a grid/list hybrid.

## Features implemented

- Mock customer data (name, points, phone, status) to simulate real app content.
- **Search** field to search by name or phone.
- **Filters** dropdown (All, Points > 50, Points > 100, Active, Inactive).
- Responsive content:
  - Small screens: stacked layouts with a vertically scrollable list of customer cards.
  - Large screens: a responsive grid of customer cards + a right-side dashboard summary panel.
- Dashboard summary card (total customers, average points, top customer).


## Reflection

- **Why responsive design matters:** Users run apps on many screen sizes and orientations. Responsive UIs ensure content remains usable and readable across devices.
- **Challenges faced:** Balancing list vs grid presentation and preventing overflow while keeping controls accessible; `Expanded` and Flexible layout helpers were key.
- **How MediaQuery and Expanded help:** `MediaQuery` drives conditional layout logic, while `Expanded` ensures children fill available space proportionally and respond to size changes.

## Screenshots

 
 ![](screenshots/Responsive(12%20pro).png)
 ![](screenshots/Responsive(ipad).png)

---


