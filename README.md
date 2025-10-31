# HR-System (Think for a name for the application, we will sooner or later create a GUI,
# so it you can also think of a name that matches the theme of the UI we are going to create, 
# or it can be just a good name regardless of the theme)

# Workflow For Milestone 2

1. **Base File**
   - `base_setup.sql` in the `main` branch creates the database and basic setup.

2. **Branches**
   - Create **5 branches** (one per task type).  
   - Each branch has its own `.sql` file containing its work.  

3. **Development**
   - Each member works **only on their branch and file**.
   - Commit and push changes frequently.
   - Write clear commit messages.

4. **Merging**
   - When done, merge all 5 branches into `main`.
   - All `.sql` files will then be combined (possibly into 1 folder for all queries).

5. **Final File**
   - Concatenate all `.sql` files into one submission file:
     ```bash
     cat base_setup.sql tables.sql functions.sql procedures.sql views.sql inserts.sql > final_database.sql
     ```
   - (Use `type` instead of `cat` on Windows.)

---

## Notes
- Only SQL scripts are tracked — no `.mdf`, `.ldf`, or backup files.  
- Follow consistent SQL formatting and naming.
- Provide documentation for your queries 
- The final deliverable is a single `final_database.sql` file containing the complete database.

