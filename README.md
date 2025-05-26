# 🏅 Olympic Games SQL Analysis

Welcome to my fourth SQL pet-project!

This project is a comprehensive SQL-based analysis of the Olympic Games dataset, focusing on athlete performances, nation-wise medal distributions, and participation statistics. The project uses structured queries to uncover historical insights and patterns in the Olympic Games data.

## 📂 Dataset

The project works with two main tables:

- **`olympics_history`**: Contains records of athletes, their attributes, events, and medals.
- **`olympics_history_noc_regions`**: Maps each National Olympic Committee (NOC) to its region/country.

Missing values like `'NA'` in age, height, weight, and medal columns were cleaned and replaced with `NULL`, and data types were appropriately cast for analysis.

---

## 📊 Analysis Overview

This project answers 20 analytical questions using SQL. Below is a summary of each:

1. **Total number of Olympic Games held**  
2. **List of all Olympic Games and host cities**  
3. **Number of participating nations in each game**  
4. **Year with the highest and lowest number of participating countries**  
5. **Countries that participated in all Olympic Games**  
6. **Sports played in every Summer Olympics**  
7. **Sports played only once in Olympic history**  
8. **Number of sports played per Olympic Games**  
9. **Oldest athlete to win a gold medal**  
10. **Male-to-female athlete participation ratio**  
11. **Top 5 athletes with most gold medals**  
12. **Top 5 athletes with most total medals**  
13. **Top 5 countries with the most medals overall**  
14. **Total gold, silver, and bronze medals won by each country**  
15. **Medal breakdown per country for each Olympic Games**  
16. **Country with the most gold, silver, and bronze medals in each game**  
17. **Countries with most gold, silver, bronze, and total medals per game**  
18. **Countries that never won gold but won silver/bronze**  
19. **Sport/event where India won the most medals**  
20. **India's Hockey medal wins across different Olympic Games**

---

## ⚙️ Technologies Used

- **PostgreSQL**
- SQL window functions (`RANK`, `DENSE_RANK`, `FIRST_VALUE`)
- Common Table Expressions (CTEs)
- Aggregation & joins
- Data cleaning & transformation

---

## 📌 How to Use

1. Clone the repository
2. Import the data into your PostgreSQL database
3. Run the SQL script provided in your database environment (e.g., pgAdmin, DBeaver, or psql)
4. Modify or extend the analysis as needed for further insights

---

## 📈 Insights

- Participation and medal trends across years
- Identification of consistently successful nations and athletes
- India's performance in Hockey and other sports
- Gender disparity in Olympic participation

---

## 🧠 Author Notes

This project serves as both an analytical exercise and a showcase of SQL proficiency, particularly in data cleaning, window functions, and multi-step CTE-based analysis.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

