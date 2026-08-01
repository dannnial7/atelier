using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ManageCourses : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["firstName"] == null)
            {
                Response.Redirect("~/Login.aspx");
            }

            if (Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadCategories();
                LoadExistingThumbnails();
                LoadCourses();
            }
        }

        private void LoadExistingThumbnails()
        {
            ddlExistingThumbnail.Items.Clear();
            ddlExistingThumbnail.Items.Add(new ListItem("-- Select Existing Thumbnail --", ""));

            HashSet<string> loadedPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            // 1. Load distinct thumbnails directly from Courses database table
            try
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString);
                SqlCommand cmd = new SqlCommand("SELECT DISTINCT Thumbnail FROM Courses WHERE Thumbnail IS NOT NULL AND Thumbnail <> ''", con);
                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string dbThumb = reader["Thumbnail"].ToString();
                    if (!string.IsNullOrEmpty(dbThumb) && !loadedPaths.Contains(dbThumb))
                    {
                        loadedPaths.Add(dbThumb);
                        string displayName = "[DB Used] " + System.IO.Path.GetFileName(dbThumb);
                        ddlExistingThumbnail.Items.Add(new ListItem(displayName, dbThumb));
                    }
                }
                con.Close();
            }
            catch { }

            // 2. Load images from ~/Images/Courses/ directory
            string folderPath = Server.MapPath("~/Images/Courses/");
            if (System.IO.Directory.Exists(folderPath))
            {
                string[] files = System.IO.Directory.GetFiles(folderPath);
                foreach (string file in files)
                {
                    string fileName = System.IO.Path.GetFileName(file);
                    string relPath = "~/Images/Courses/" + fileName;
                    if (!loadedPaths.Contains(relPath))
                    {
                        loadedPaths.Add(relPath);
                        ddlExistingThumbnail.Items.Add(new ListItem(fileName, relPath));
                    }
                }
            }
        }

        private void LoadCategories()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT CategoryID, CategoryName " +
                "FROM CourseCategories " +
                "ORDER BY CategoryName", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlCategory.DataSource = dt;
            ddlCategory.DataTextField = "CategoryName";
            ddlCategory.DataValueField = "CategoryID";
            ddlCategory.DataBind();

            ddlCategory.Items.Insert(0,
                new ListItem("-- Select Category --", "0"));
        }

        private void LoadCourses()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter("SELECT C.CourseID, C.Title, " + "C.Price, C.Difficulty, " + "C.IsPublished, C.Thumbnail, " + "CC.CategoryName, " + "(SELECT COUNT(*) FROM Enrollments E " +
    "WHERE E.CourseID = C.CourseID) " + "AS EnrollmentCount " + "FROM Courses C " + "JOIN CourseCategories CC " + "ON C.CategoryID = CC.CategoryID " + "ORDER BY C.CourseID DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCourses.DataSource = dt;
            gvCourses.DataBind();

            lblCourseCount.Text =
                dt.Rows.Count.ToString();
        }

        protected void btnShowAdd_Click(
            object sender, EventArgs e)
        {
            hdnCourseID.Value = "0";
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtPrice.Text = "0.00";
            txtThumbnail.Text = "";
            if (ddlExistingThumbnail.Items.Count > 0) ddlExistingThumbnail.SelectedIndex = 0;
            chkPublished.Checked = true;
            ddlDifficulty.SelectedIndex = 0;
            lblFormTitle.Text = "Add New Course";

            formPanel.Style["display"] = "block";
        }

        protected void btnCancel_Click(
            object sender, EventArgs e)
        {
            formPanel.Style["display"] = "none";
            lblMessage.Visible = false;
        }

        protected void btnSave_Click(
            object sender, EventArgs e)
        {
            // Determine thumbnail path
            string thumbnailPath = txtThumbnail.Text;

            if (fuThumbnail.HasFile)
            {
                try
                {
                    string ext = System.IO.Path.GetExtension(fuThumbnail.FileName).ToLower();
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp")
                    {
                        string folderPath = Server.MapPath("~/Images/Courses/");
                        if (!System.IO.Directory.Exists(folderPath))
                        {
                            System.IO.Directory.CreateDirectory(folderPath);
                        }
                        string newFileName = Guid.NewGuid().ToString("N") + ext;
                        string savePath = System.IO.Path.Combine(folderPath, newFileName);
                        fuThumbnail.SaveAs(savePath);
                        thumbnailPath = "~/Images/Courses/" + newFileName;
                    }
                }
                catch { }
            }
            else if (!string.IsNullOrEmpty(ddlExistingThumbnail.SelectedValue))
            {
                thumbnailPath = ddlExistingThumbnail.SelectedValue;
            }

            if (string.IsNullOrEmpty(thumbnailPath))
            {
                thumbnailPath = "~/Images/Courses/Visual-Arts.jpg";
            }

            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            int courseID =
                Convert.ToInt32(hdnCourseID.Value);

            if (courseID == 0)
            {

                SqlCommand cmd = new SqlCommand("INSERT INTO Courses " + "(Title, Description, CategoryID, " + "Price, Difficulty, IsPublished, " +
                    "CreatedBy, Thumbnail) " + "VALUES " + "(@title, @desc, @catID, " + "@price, @diff, @pub, @by, @thumb)", con);

                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@desc", txtDescription.Text);
                cmd.Parameters.AddWithValue(
                    "@catID", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@price", txtPrice.Text);
                cmd.Parameters.AddWithValue(
                    "@diff", ddlDifficulty.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@pub", chkPublished.Checked ? 1 : 0);
                cmd.Parameters.AddWithValue(
                    "@by", Session["userID"]);
                cmd.Parameters.AddWithValue(
                    "@thumb", thumbnailPath);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Course added successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }
            else
            {
                SqlCommand cmd = new SqlCommand("UPDATE Courses SET " + "Title = @title, " + "Description = @desc, " + "CategoryID = @catID, " + "Price = @price, " +
                    "Difficulty = @diff, " + "IsPublished = @pub, " + "Thumbnail = @thumb " + "WHERE CourseID = @id", con);

                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@desc", txtDescription.Text);
                cmd.Parameters.AddWithValue(
                    "@catID", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@price", txtPrice.Text);
                cmd.Parameters.AddWithValue(
                    "@diff", ddlDifficulty.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@pub", chkPublished.Checked ? 1 : 0);
                cmd.Parameters.AddWithValue(
                    "@thumb", thumbnailPath);
                cmd.Parameters.AddWithValue(
                    "@id", courseID);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Course updated successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }

            con.Close();

            formPanel.Style["display"] = "none";
            lblMessage.Visible = true;
            LoadExistingThumbnails();
            LoadCourses();
        }

        protected void gvCourses_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            int courseID =
                Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditCourse")
            {
                // Load course data into form
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da =
                    new SqlDataAdapter(
                    "SELECT * FROM Courses " +
                    "WHERE CourseID = " + courseID,
                    con);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    hdnCourseID.Value =
                        courseID.ToString();
                    txtTitle.Text =
                        dt.Rows[0]["Title"].ToString();
                    txtDescription.Text =
                        dt.Rows[0]["Description"]
                        .ToString();
                    txtPrice.Text =
                        dt.Rows[0]["Price"].ToString();

                    string existingThumb = dt.Rows[0]["Thumbnail"].ToString();
                    txtThumbnail.Text = existingThumb;

                    if (ddlExistingThumbnail.Items.FindByValue(existingThumb) != null)
                    {
                        ddlExistingThumbnail.SelectedValue = existingThumb;
                    }
                    else
                    {
                        if (ddlExistingThumbnail.Items.Count > 0) ddlExistingThumbnail.SelectedIndex = 0;
                    }

                    chkPublished.Checked =
                        Convert.ToBoolean(
                        dt.Rows[0]["IsPublished"]);
                    ddlDifficulty.SelectedValue =
                        dt.Rows[0]["Difficulty"]
                        .ToString();
                    ddlCategory.SelectedValue =
                        dt.Rows[0]["CategoryID"]
                        .ToString();

                    lblFormTitle.Text =
                        "Edit Course";
                    formPanel.Style["display"] =
                        "block";
                }
            }
            else if (e.CommandName == "DeleteCourse")
            {
                using (SqlConnection con = new SqlConnection(
                    ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        try
                        {
                            // 1. Delete option records for questions under assessments of this course
                            string deleteOptionsSql = @"
                                DELETE FROM Options 
                                WHERE QuestionID IN (
                                    SELECT Q.QuestionID 
                                    FROM Questions Q 
                                    JOIN Assessments A ON Q.AssessmentID = A.AssessmentID 
                                    WHERE A.CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteOptionsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 2. Delete questions under assessments of this course
                            string deleteQuestionsSql = @"
                                DELETE FROM Questions 
                                WHERE AssessmentID IN (
                                    SELECT AssessmentID FROM Assessments WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteQuestionsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 3. Delete submissions for assessments of this course
                            string deleteSubmissionsSql = @"
                                DELETE FROM Submissions 
                                WHERE AssessmentID IN (
                                    SELECT AssessmentID FROM Assessments WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteSubmissionsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 4. Delete assessment results
                            string deleteResultsSql = @"
                                DELETE FROM AssessmentsResults 
                                WHERE AssessmentID IN (
                                    SELECT AssessmentID FROM Assessments WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteResultsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 5. Delete assessments
                            string deleteAssessmentsSql = "DELETE FROM Assessments WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteAssessmentsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 6. Delete notes linked to modules of this course
                            string deleteNotesSql = @"
                                DELETE FROM Notes 
                                WHERE ModuleID IN (
                                    SELECT ModuleID FROM Modules WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteNotesSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 7. Delete module progress records
                            string deleteModProgressSql = @"
                                DELETE FROM ModuleProgress 
                                WHERE ModuleID IN (
                                    SELECT ModuleID FROM Modules WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteModProgressSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 8. Delete modules
                            string deleteModulesSql = "DELETE FROM Modules WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteModulesSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 9. Delete course skills
                            string deleteCourseSkillsSql = "DELETE FROM CourseSkills WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteCourseSkillsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 10. Delete forum replies & forum threads
                            string deleteForumRepliesSql = @"
                                DELETE FROM ForumReplies 
                                WHERE ForumID IN (
                                    SELECT ForumID FROM Forum WHERE CourseID = @courseID
                                )";
                            using (SqlCommand cmd = new SqlCommand(deleteForumRepliesSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            string deleteForumSql = "DELETE FROM Forum WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteForumSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 11. Delete enrollments
                            string deleteEnrollmentsSql = "DELETE FROM Enrollments WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteEnrollmentsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 12. Delete payments
                            string deletePaymentsSql = "DELETE FROM Payments WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deletePaymentsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 13. Delete user skills
                            string deleteUserSkillsSql = "DELETE FROM UserSkills WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteUserSkillsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 14. Delete portfolio items
                            string deletePortfolioSql = "DELETE FROM PortfolioItems WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deletePortfolioSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 15. Delete reviews
                            string deleteReviewsSql = "DELETE FROM Reviews WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteReviewsSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            // 16. Finally delete the course itself
                            string deleteCourseSql = "DELETE FROM Courses WHERE CourseID = @courseID";
                            using (SqlCommand cmd = new SqlCommand(deleteCourseSql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@courseID", courseID);
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();

                            lblMessage.Text = "Course and all related records deleted successfully!";
                            lblMessage.CssClass = "alert alert-success";
                            lblMessage.Visible = true;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            lblMessage.Text = "Error deleting course: " + ex.Message;
                            lblMessage.CssClass = "alert alert-danger";
                            lblMessage.Visible = true;
                        }
                    }
                }

                LoadCourses();
            }

        }
    
    protected void btnSearch_Click(
    object sender, EventArgs e)
        {
            string search = txtSearch.Text.Trim();

            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT C.CourseID, C.Title, " +
                "C.Price, C.Difficulty, " +
                "C.IsPublished, C.Thumbnail, " +
                "CC.CategoryName, " +
                "(SELECT COUNT(*) FROM Enrollments E " +
                "WHERE E.CourseID = C.CourseID) " +
                "AS EnrollmentCount " +
                "FROM Courses C " +
                "JOIN CourseCategories CC " +
                "ON C.CategoryID = CC.CategoryID " +
                "WHERE C.Title LIKE '%" + search + "%' " +
                "OR CC.CategoryName LIKE '%" +
                search + "%' " +
                "ORDER BY C.CourseID DESC", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCourses.DataSource = dt;
            gvCourses.DataBind();
            lblCourseCount.Text =
                dt.Rows.Count.ToString();
        }

        protected void btnReset_Click(
            object sender, EventArgs e)
        {
            txtSearch.Text = "";
            LoadCourses();
        }
    }
    }