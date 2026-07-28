using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class QuizResults : Page
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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (AssessmentId == 0)
                {
                    pnlResults.Visible = false;
                    pnlNoResults.Visible = true;
                    return;
                }

                LoadAssessmentInfo();
                LoadLatestResult();
                LoadHistory();
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

        private void LoadAssessmentInfo()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT CourseID, Title, PassMark, MaxAttempts " +
                    "FROM Assessments WHERE AssessmentID = @AssessmentID", con);
                cmd.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    int courseId = Convert.ToInt32(dr["CourseID"]);

                    litTitle.Text = dr["Title"].ToString();
                    lblPassMark.Text = dr["PassMark"] + "%";

                    ViewState["CourseId"] = courseId;
                    ViewState["MaxAttempts"] = Convert.ToInt32(dr["MaxAttempts"]);

                    lnkBackToCourse.NavigateUrl = "CourseDetail.aspx?id=" + courseId;
                    lnkTakeQuiz.NavigateUrl = "QuizPage.aspx?id=" + AssessmentId;
                    lnkRetake.NavigateUrl = "QuizPage.aspx?id=" + AssessmentId;
                    lnkCertificate.NavigateUrl = "Certificate.aspx?id=" + courseId;
                }
                dr.Close();
            }
        }

        // The most recent attempt is shown prominently, since that is what the
        // learner has just completed.
        private void LoadLatestResult()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 Score, Passed, AttemptNumber, TakenAt " +
                    "FROM AssessmentsResults " +
                    "WHERE UserID = @UserID AND AssessmentID = @AssessmentID " +
                    "ORDER BY TakenAt DESC", con);
                cmd.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                cmd.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (!dr.Read())
                {
                    dr.Close();
                    pnlResults.Visible = false;
                    pnlNoResults.Visible = true;
                    return;
                }

                int score = Convert.ToInt32(dr["Score"]);
                bool passed = Convert.ToBoolean(dr["Passed"]);
                int attemptNo = Convert.ToInt32(dr["AttemptNumber"]);

                lblScore.Text = score + "%";
                lblAttempt.Text = attemptNo.ToString();
                litTakenAt.Text = Convert.ToDateTime(dr["TakenAt"])
                    .ToString("dd MMM yyyy, h:mm tt");

                if (passed)
                {
                    litOutcome.Text =
                        "<span class='badge badge-success'>Passed</span>" +
                        "<p style='margin-top:12px'>Well done. You have passed this assessment.</p>";
                }
                else
                {
                    litOutcome.Text =
                        "<span class='badge badge-danger'>Not passed</span>" +
                        "<p style='margin-top:12px'>You did not reach the pass mark this time.</p>";
                }

                dr.Close();

                ShowNextStep(passed, attemptNo);
            }
        }

        // A learner who has passed is offered their certificate; one who has not
        // is offered another attempt, provided any remain.
        private void ShowNextStep(bool passed, int attemptNo)
        {
            int maxAttempts = Convert.ToInt32(ViewState["MaxAttempts"]);

            if (passed)
            {
                lnkCertificate.Visible = true;
            }
            else if (attemptNo < maxAttempts)
            {
                lnkRetake.Visible = true;
            }
            else
            {
                lblNoAttemptsLeft.Visible = true;
            }
        }

        private void LoadHistory()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT Score, Passed, AttemptNumber, TakenAt " +
                    "FROM AssessmentsResults " +
                    "WHERE UserID = @UserID AND AssessmentID = @AssessmentID " +
                    "ORDER BY AttemptNumber", con);
                da.SelectCommand.Parameters.AddWithValue("@UserID", GetCurrentUserId());
                da.SelectCommand.Parameters.AddWithValue("@AssessmentID", AssessmentId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptHistory.DataSource = dt;
                rptHistory.DataBind();
            }
        }
    }
}