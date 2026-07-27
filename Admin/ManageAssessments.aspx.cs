using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Atelier.Admin
{
    public partial class ManageAssessments : System.Web.UI.Page
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
                LoadCourses();
                LoadAssessments();
            }
        }

        private void LoadCourses()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter( "SELECT CourseID, Title " + "FROM Courses ORDER BY Title", con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "Title";
            ddlCourse.DataValueField = "CourseID";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0,
                new ListItem("-- Select Course --", "0"));
        }

        private void LoadAssessments()
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT A.AssessmentID, A.Title, " +
                "A.TimeLimit, A.PassMark, " +
                "A.MaxAttempts, C.Title AS CourseTitle, " +
                "(SELECT COUNT(*) FROM Questions Q " +
                "WHERE Q.AssessmentID = A.AssessmentID) " +
                "AS QuestionCount " +
                "FROM Assessments A " +
                "JOIN Courses C " +
                "ON A.CourseID = C.CourseID " +
                "ORDER BY C.Title", con);

            DataTable dt = new DataTable();
            da.Fill(dt);


            gvAssessments.DataSource = dt;
            gvAssessments.DataBind();

            lblCount.Text = dt.Rows.Count.ToString();
        }

        private void LoadQuestions(int assessmentID)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            SqlDataAdapter da = new SqlDataAdapter( "SELECT QuestionID, QuestionText, " + "OrderIndex FROM Questions " +  "WHERE AssessmentID = " + assessmentID +
                " ORDER BY OrderIndex", con);
                      DataTable dt = new DataTable();
            da.Fill(dt);

            gvQuestions.DataSource = dt;
            gvQuestions.DataBind();
        }

        protected void btnShowAdd_Click(
            object sender, EventArgs e)
        {
            hdnAssessmentID.Value = "0";
            txtTitle.Text = "";
            txtTimeLimit.Text = "30";
            txtPassMark.Text = "60";
            txtMaxAttempts.Text = "3";
            ddlCourse.SelectedIndex = 0;
            lblFormTitle.Text = "Add Assessment";
            formPanel.Style["display"] = "block";
            questionsPanel.Style["display"] = "none";
        }

        protected void btnCancel_Click(
            object sender, EventArgs e)
        {
            formPanel.Style["display"] = "none";
        }

        protected void btnSave_Click(
            object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            int assessmentID = Convert.ToInt32(
                hdnAssessmentID.Value);

            if (assessmentID == 0)
            {
                SqlCommand cmd = new SqlCommand( "INSERT INTO Assessments " + "(CourseID, Title, TimeLimit, " +  "PassMark, MaxAttempts) " + "VALUES (@courseID, @title, " +
                    "@time, @pass, @attempts)", con);
                cmd.Parameters.AddWithValue(
                    "@courseID", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue(
                    "@title", txtTitle.Text);
                cmd.Parameters.AddWithValue(
                    "@time", txtTimeLimit.Text);
                cmd.Parameters.AddWithValue(
                    "@pass", txtPassMark.Text);
                cmd.Parameters.AddWithValue(
                    "@attempts", txtMaxAttempts.Text);

                cmd.ExecuteNonQuery();

                lblMessage.Text =
                    "Assessment added successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
            }
            else
            {
                             SqlCommand cmd = new SqlCommand(
                            "UPDATE Assessments SET " +
                            "CourseID = @courseID, " +
                            "Title = @title, " +
                            "TimeLimit = @time, " +
                            "PassMark = @pass, " +
                            "MaxAttempts = @attempts " +
                            "WHERE AssessmentID = @id", con);

                        cmd.Parameters.AddWithValue(
                            "@courseID", ddlCourse.SelectedValue);
                        cmd.Parameters.AddWithValue(
                            "@title", txtTitle.Text);
                        cmd.Parameters.AddWithValue(
                            "@time", txtTimeLimit.Text);
                        cmd.Parameters.AddWithValue(
                            "@pass", txtPassMark.Text);
                        cmd.Parameters.AddWithValue(
                            "@attempts", txtMaxAttempts.Text);
                        cmd.Parameters.AddWithValue(
                            "@id", assessmentID);

                        cmd.ExecuteNonQuery();

                        lblMessage.Text =
                            "Assessment updated successfully!";
                        lblMessage.CssClass =
                            "alert alert-success";
            }

            con.Close();

            formPanel.Style["display"] = "none";
            lblMessage.Visible = true;
            LoadAssessments();
        }

        protected void gvAssessments_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            int assessmentID = Convert.ToInt32(
                e.CommandArgument);

            if (e.CommandName == "EditAssessment")
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlDataAdapter da =
                    new SqlDataAdapter( "SELECT * FROM Assessments " + "WHERE AssessmentID = " +  assessmentID, con);
                     DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    hdnAssessmentID.Value =
                        assessmentID.ToString();
                    txtTitle.Text =
                        dt.Rows[0]["Title"].ToString();
                    txtTimeLimit.Text =
                        dt.Rows[0]["TimeLimit"]
                        .ToString();
                    txtPassMark.Text =
                        dt.Rows[0]["PassMark"].ToString();
                    txtMaxAttempts.Text =
                        dt.Rows[0]["MaxAttempts"]
                        .ToString();
                    ddlCourse.SelectedValue =
                        dt.Rows[0]["CourseID"].ToString();

                    lblFormTitle.Text =
                        "Edit Assessment";
                    formPanel.Style["display"] = "block";
                    questionsPanel.Style["display"] =
                        "none";
                }
            }
            else if (e.CommandName == "ManageQuestions")
            {
                hdnSelectedAssessmentID.Value =
                    assessmentID.ToString();

                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand( "SELECT Title FROM Assessments " + "WHERE AssessmentID = " +  assessmentID, con);
                con.Open();
                lblAssessmentName.Text =
                    cmd.ExecuteScalar().ToString();
                con.Close();

                LoadQuestions(assessmentID);
                questionsPanel.Style["display"] = "block";
                formPanel.Style["display"] = "none";
            }
            else if (e.CommandName == "DeleteAssessment")
            {
                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand( "DELETE FROM Assessments " +  "WHERE AssessmentID = " +  assessmentID, con);
                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                lblMessage.Text =
                    "Assessment deleted successfully!";
                lblMessage.CssClass =
                    "alert alert-success";
                lblMessage.Visible = true;

                LoadAssessments();
            }
        }

        protected void btnAddQuestion_Click(
            object sender, EventArgs e)
        {
            int assessmentID = Convert.ToInt32(
                hdnSelectedAssessmentID.Value);

            SqlConnection con = new SqlConnection(
                ConfigurationManager
                .ConnectionStrings["ConnectionString"]
                .ConnectionString);

            con.Open();

            SqlCommand cmdOrder = new SqlCommand(
                "SELECT ISNULL(MAX(OrderIndex), 0) + 1 " +
                "FROM Questions WHERE AssessmentID = " +
                assessmentID, con);
            int orderIndex = Convert.ToInt32(
                cmdOrder.ExecuteScalar());

            SqlCommand cmdQ = new SqlCommand(
                "INSERT INTO Questions " +
                "(AssessmentID, QuestionText, " +
                "QuestionType, OrderIndex, Marks) " +
                "VALUES (@aid, @text, 'MCQ', " +
                "@order, 1); " +
                "SELECT SCOPE_IDENTITY()", con);

            cmdQ.Parameters.AddWithValue(
                "@aid", assessmentID);
            cmdQ.Parameters.AddWithValue(
                "@text", txtQuestion.Text);
            cmdQ.Parameters.AddWithValue(
                "@order", orderIndex);

            int questionID = Convert.ToInt32(
                cmdQ.ExecuteScalar());

            string[] options = {
                txtOptionA.Text,
                txtOptionB.Text,
                txtOptionC.Text,
                txtOptionD.Text
            };

            string correct =
                ddlCorrectAnswer.SelectedValue;

            for (int i = 0; i < 4; i++)
            {
                string letter =
                    new string[] { "A", "B", "C", "D" }[i];
                int isCorrect =
                    (letter == correct) ? 1 : 0;

                SqlCommand cmdO = new SqlCommand(
                    "INSERT INTO Options " +
                    "(QuestionID, OptionText, IsCorrect) " +
                    "VALUES (@qid, @text, @correct)",
                    con);

                cmdO.Parameters.AddWithValue(
                    "@qid", questionID);
                cmdO.Parameters.AddWithValue(
                    "@text", options[i]);
                cmdO.Parameters.AddWithValue(
                    "@correct", isCorrect);

                cmdO.ExecuteNonQuery();
            }

            con.Close();
            txtQuestion.Text = "";
            txtOptionA.Text = "";
            txtOptionB.Text = "";
            txtOptionC.Text = "";
            txtOptionD.Text = "";
            ddlCorrectAnswer.SelectedIndex = 0;

            LoadQuestions(assessmentID);
            LoadAssessments();
        }

        protected void gvQuestions_RowCommand(
            object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteQuestion")
            {
                int questionID = Convert.ToInt32(
                    e.CommandArgument);

                SqlConnection con = new SqlConnection(
                    ConfigurationManager
                    .ConnectionStrings["ConnectionString"]
                    .ConnectionString);

                SqlCommand cmd = new SqlCommand(
                    "DELETE FROM Questions " +
                    "WHERE QuestionID = " + questionID,
                    con);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                int assessmentID = Convert.ToInt32(
                    hdnSelectedAssessmentID.Value);
                LoadQuestions(assessmentID);
                LoadAssessments();
            }
        }
                protected void btnCloseQuestions_Click(
            object sender, EventArgs e)
        {
            questionsPanel.Style["display"] = "none";
        }
    }
}