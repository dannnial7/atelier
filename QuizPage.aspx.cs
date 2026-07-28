using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Atelier
{
    public partial class QuizPage : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        private int AssessmentId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        private int CourseId
        {
            get { return ViewState["CourseId"] != null ? (int)ViewState["CourseId"] : 0; }
            set { ViewState["CourseId"] = value; }
        }

        private int AttemptNumber
        {
            get { return ViewState["AttemptNumber"] != null ? (int)ViewState["AttemptNumber"] : 1; }
            set { ViewState["AttemptNumber"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (AssessmentId == 0)
                {
                    pnlQuiz.Visible = false;
                    pnlNotFound.Visible = true;
                    return;
                }

                if (!LoadAssessment()) return;
                if (!CheckAttemptsRemaining()) return;

                LoadQuestions();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);
            if (Session["userID"] != null)
                return Convert.ToInt32(Session["userID"]);

            Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return 0;
        }

        private bool LoadAssessment()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT CourseID, Title, TimeLimit, PassMark, MaxAttempts " +
                    "FROM Assessments WHERE AssessmentID = @AssessmentID", con);
                cmd.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (!dr.Read())
                {
                    dr.Close();
                    pnlQuiz.Visible = false;
                    pnlNotFound.Visible = true;
                    return false;
                }

                CourseId = Convert.ToInt32(dr["CourseID"]);
                litTitle.Text = dr["Title"].ToString();
                lblTimeLimit.Text = dr["TimeLimit"].ToString();
                lblPassMark.Text = dr["PassMark"].ToString();

                ViewState["PassMark"] = Convert.ToInt32(dr["PassMark"]);
                ViewState["MaxAttempts"] = Convert.ToInt32(dr["MaxAttempts"]);

                string backUrl = "CourseDetail.aspx?id=" + CourseId;
                lnkBackToCourse.NavigateUrl = backUrl;
                lnkBackNoAttempts.NavigateUrl = backUrl;

                dr.Close();
                return true;
            }
        }

        // Each assessment allows a fixed number of attempts, so the number
        // already used is counted before the questions are shown at all.
        private bool CheckAttemptsRemaining()
        {
            int maxAttempts = Convert.ToInt32(ViewState["MaxAttempts"]);

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM AssessmentsResults " +
                    "WHERE UserID = @UserID AND AssessmentID = @AssessmentID", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                cmd.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                con.Open();
                int used = Convert.ToInt32(cmd.ExecuteScalar());

                if (used >= maxAttempts)
                {
                    pnlQuiz.Visible = false;
                    pnlNoAttempts.Visible = true;
                    litMaxAttempts.Text = maxAttempts.ToString();
                    return false;
                }

                AttemptNumber = used + 1;
                lblAttemptsLeft.Text = (maxAttempts - used).ToString();
                return true;
            }
        }

        private void LoadQuestions()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT QuestionID, QuestionText FROM Questions " +
                    "WHERE AssessmentID = @AssessmentID ORDER BY OrderIndex", con);
                da.SelectCommand.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                lblQuestionCount.Text = dt.Rows.Count.ToString();
                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
            }
        }

        // Each question's options are loaded as its row is bound, so the radio
        // list belongs to that specific question.
        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            HiddenField hf = (HiddenField)e.Item.FindControl("hfQuestionID");
            RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT OptionID, OptionText FROM Options " +
                    "WHERE QuestionID = @QuestionID", con);
                da.SelectCommand.Parameters.AddWithValue("@QuestionID", hf.Value);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rbl.DataSource = dt;
                rbl.DataTextField = "OptionText";
                rbl.DataValueField = "OptionID";
                rbl.DataBind();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int totalQuestions = 0;
            int correctAnswers = 0;
            bool allAnswered = true;

            // Answers are graded against the IsCorrect flag held in the database
            // rather than anything stored on the page, so the correct answers are
            // never sent to the browser.
            foreach (RepeaterItem item in rptQuestions.Items)
            {
                if (item.ItemType != ListItemType.Item &&
                    item.ItemType != ListItemType.AlternatingItem) continue;

                totalQuestions++;

                RadioButtonList rbl = (RadioButtonList)item.FindControl("rblOptions");

                if (rbl.SelectedItem == null)
                {
                    allAnswered = false;
                    continue;
                }

                using (SqlConnection con = new SqlConnection(ConnStr))
                {
                    SqlCommand cmd = new SqlCommand(
                        "SELECT IsCorrect FROM Options WHERE OptionID = @OptionID", con);
                    cmd.Parameters.AddWithValue("@OptionID", rbl.SelectedValue);

                    con.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null && Convert.ToBoolean(result))
                        correctAnswers++;
                }
            }

            if (!allAnswered)
            {
                pnlValidationMsg.Visible = true;
                return;
            }

            int passMark = Convert.ToInt32(ViewState["PassMark"]);
            int score = totalQuestions > 0
                ? (int)Math.Round((double)correctAnswers / totalQuestions * 100)
                : 0;
            bool passed = score >= passMark;

            SaveResult(score, passed, correctAnswers, totalQuestions);

            Response.Redirect("QuizResults.aspx?id=" + AssessmentId);
        }

        private void SaveResult(int score, bool passed, int correct, int total)
        {
            int userId = GetCurrentUserId();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    "INSERT INTO AssessmentsResults " +
                    "(UserID, AssessmentID, Score, Passed, AttemptNumber) " +
                    "VALUES (@UserID, @AssessmentID, @Score, @Passed, @AttemptNumber)", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@AssessmentID", AssessmentId);
                cmd.Parameters.AddWithValue("@Score", score);
                cmd.Parameters.AddWithValue("@Passed", passed);
                cmd.Parameters.AddWithValue("@AttemptNumber", AttemptNumber);
                cmd.ExecuteNonQuery();

                // Passing an assessment awards experience points, which the
                // dashboard and leaderboard both read from this log.
                if (passed)
                {
                    SqlCommand xp = new SqlCommand(
                        "INSERT INTO XPLogs (UserID, PointsEarned, Reason) " +
                        "VALUES (@UserID, 100, 'Passed an assessment')", con);
                    xp.Parameters.AddWithValue("@UserID", userId);
                    xp.ExecuteNonQuery();
                }

                SqlCommand notify = new SqlCommand(
                    "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                    "VALUES (@UserID, @Title, @Body, 'assessment')", con);
                notify.Parameters.AddWithValue("@UserID", userId);
                notify.Parameters.AddWithValue("@Title",
                    passed ? "Assessment passed" : "Assessment attempted");
                notify.Parameters.AddWithValue("@Body",
                    "You scored " + score + "% (" + correct + " of " + total + " correct).");
                notify.ExecuteNonQuery();
            }

            BadgeHelper.EvaluateBadges(userId);
        }
    }
}