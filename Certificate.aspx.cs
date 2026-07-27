using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Certificate : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        private int CourseId
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
                if (CourseId == 0)
                {
                    pnlNotEligible.Visible = true;
                    return;
                }

                string backUrl = "CourseDetail.aspx?id=" + CourseId;
                lnkBackToCourse.NavigateUrl = backUrl;
                lnkBack.NavigateUrl = backUrl;

                CheckEligibilityAndRender();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 2; // TEMPORARY: see Dashboard.aspx.cs
        }

        // A certificate is only issued where both requirements are met, so both
        // are checked before anything is rendered.
        private void CheckEligibilityAndRender()
        {
            int userId = GetCurrentUserId();

            int totalModules = 0;
            int completedModules = 0;
            bool passedAssessment = false;
            int bestScore = 0;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                SqlCommand cmdModules = new SqlCommand(
                    "SELECT " +
                    "  (SELECT COUNT(*) FROM Modules WHERE CourseID = @CourseID) AS Total, " +
                    "  (SELECT COUNT(*) FROM ModuleProgress MP " +
                    "     JOIN Modules M ON MP.ModuleID = M.ModuleID " +
                    "     WHERE M.CourseID = @CourseID AND MP.UserID = @UserID " +
                    "       AND MP.IsCompleted = 1) AS Done", con);
                cmdModules.Parameters.AddWithValue("@CourseID", CourseId);
                cmdModules.Parameters.AddWithValue("@UserID", userId);

                SqlDataReader dr = cmdModules.ExecuteReader();
                if (dr.Read())
                {
                    totalModules = Convert.ToInt32(dr["Total"]);
                    completedModules = Convert.ToInt32(dr["Done"]);
                }
                dr.Close();

                // The best passing score is used, so a later weaker attempt
                // does not replace an earlier stronger one on the certificate.
                SqlCommand cmdAssessment = new SqlCommand(
                    "SELECT MAX(AR.Score) AS BestScore " +
                    "FROM AssessmentsResults AR " +
                    "JOIN Assessments A ON AR.AssessmentID = A.AssessmentID " +
                    "WHERE A.CourseID = @CourseID AND AR.UserID = @UserID " +
                    "  AND AR.Passed = 1", con);
                cmdAssessment.Parameters.AddWithValue("@CourseID", CourseId);
                cmdAssessment.Parameters.AddWithValue("@UserID", userId);

                object result = cmdAssessment.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    passedAssessment = true;
                    bestScore = Convert.ToInt32(result);
                }
            }

            bool allModulesDone = totalModules > 0 && completedModules >= totalModules;

            if (allModulesDone && passedAssessment)
            {
                RenderCertificate(userId, bestScore);
            }
            else
            {
                ShowRequirements(totalModules, completedModules, passedAssessment);
            }
        }

        private void ShowRequirements(int total, int done, bool passed)
        {
            litModuleProgress.Text = done + " of " + total + " completed";

            litAssessmentStatus.Text = passed
                ? "<span class='badge badge-success'>Passed</span>"
                : "<span class='badge badge-danger'>Not yet passed</span>";

            pnlNotEligible.Visible = true;
        }

        private void RenderCertificate(int userId, int score)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT U.FullName, C.Title, C.Difficulty, CC.CategoryName, " +
                    "       E.CompletedAt, E.CertificateID AS CertID " +
                    "FROM Users U " +
                    "CROSS JOIN Courses C " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "LEFT JOIN Enrollments E " +
                    "  ON E.CourseID = C.CourseID AND E.UserID = U.UserID " +
                    "WHERE U.UserID = @UserID AND C.CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    litLearnerName.Text = dr["FullName"].ToString();
                    litCourseTitle.Text = dr["Title"].ToString();
                    litCategory.Text = dr["CategoryName"].ToString();
                    litDifficulty.Text = dr["Difficulty"].ToString();
                    litScore.Text = score.ToString();

                    DateTime completed = dr["CompletedAt"] == DBNull.Value
                        ? DateTime.Now
                        : Convert.ToDateTime(dr["CompletedAt"]);

                    litCompletedDate.Text = completed.ToString("dd MMMM yyyy");

                    string certId = dr["CertID"] == DBNull.Value
                        ? ""
                        : dr["CertID"].ToString();

                    dr.Close();

                    // The certificate identifier is generated on first issue and
                    // then stored, so the same certificate always carries the
                    // same reference.
                    if (string.IsNullOrEmpty(certId))
                        certId = IssueCertificate(userId, completed);

                    litCertId.Text = certId;
                    pnlCertificate.Visible = true;
                }
                else
                {
                    dr.Close();
                    pnlNotEligible.Visible = true;
                }
            }
        }

        private string IssueCertificate(int userId, DateTime completed)
        {
            string certId = "ATL-" + CourseId.ToString("D2") +
                            "-" + userId.ToString("D4") +
                            "-" + DateTime.Now.ToString("yyMM");

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "UPDATE Enrollments " +
                    "SET CertificateID = @CertID, CompletedAt = @CompletedAt " +
                    "WHERE UserID = @UserID AND CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CertID", certId);
                cmd.Parameters.AddWithValue("@CompletedAt", completed);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                cmd.ExecuteNonQuery();
            }

            return certId;
        }
    }
}