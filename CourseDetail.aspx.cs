using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class CourseDetail : Page
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

        public bool IsUserEnrolled { get; set; }

        public string FormatContentType(object rawType)
        {
            if (rawType == null || rawType == DBNull.Value) return "";
            string type = rawType.ToString().Trim().ToLower();
            if (type == "video") return "Video";
            if (type == "pdf") return "PDF";
            if (type == "text") return "Text";
            return System.Threading.Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(type);
        }

        public string FormatModuleBadge(object rawCompleted, object rawPreview)
        {
            bool completed = rawCompleted != DBNull.Value && Convert.ToBoolean(rawCompleted);
            bool preview = rawPreview != DBNull.Value && Convert.ToBoolean(rawPreview);

            if (completed)
            {
                return " &middot; <span class='badge badge-success'>Completed</span>";
            }
            if (IsUserEnrolled)
            {
                return " &middot; <span class='badge badge-info' style='background:#059669;color:#fff'>Unlocked</span>";
            }
            if (preview)
            {
                return " &middot; <span class='badge badge-info' style='background:#0284c7;color:#fff'>Preview Available</span>";
            }
            return " &middot; <span class='badge badge-secondary' style='background:#64748b;color:#fff'>Locked &#128274;</span>";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (CourseId == 0)
                {
                    pnlCourse.Visible = false;
                    pnlNotFound.Visible = true;
                    return;
                }

                IsUserEnrolled = CheckEnrollment();
                LoadCourse();
                LoadModules();
                LoadProgress();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null)
                return Convert.ToInt32(Session["UserID"]);

            return 0; // 0 indicates Guest / Not Logged In
        }

        private bool CheckEnrollment()
        {
            int userId = GetCurrentUserId();
            if (userId == 0) return false;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private void LoadCourse()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT C.Title, C.Description, C.Difficulty, C.Price, C.Thumbnail, CC.CategoryName " +
                    "FROM Courses C " +
                    "JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE C.CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    litTitle.Text = dr["Title"].ToString();
                    litDescription.Text = dr["Description"].ToString();
                    litDifficulty.Text = dr["Difficulty"].ToString();
                    litCategory.Text = dr["CategoryName"].ToString();

                    if (dr["Thumbnail"] != DBNull.Value && !string.IsNullOrEmpty(dr["Thumbnail"].ToString()))
                    {
                        string thumbUrl = ResolveUrl(dr["Thumbnail"].ToString());
                        divCourseBg.Style["background-image"] = "url('" + thumbUrl + "')";
                    }

                    decimal price = Convert.ToDecimal(dr["Price"]);
                    if (price == 0)
                    {
                        btnEnrollCourse.Text = "Enroll Now (Free)";
                    }
                    else
                    {
                        btnEnrollCourse.Text = "Enroll Now (RM " + price.ToString("F2") + ")";
                    }
                }
                else
                {
                    pnlCourse.Visible = false;
                    pnlNotFound.Visible = true;
                }
                dr.Close();
            }
        }

        protected void btnEnrollCourse_Click(object sender, EventArgs e)
        {
            int userId = GetCurrentUserId();

            // If not logged in, redirect to Register/Login with courseId
            if (userId == 0)
            {
                Response.Redirect("~/Register.aspx?courseId=" + CourseId);
                return;
            }

            // Check if course is free or paid
            decimal price = 0;
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT Price FROM Courses WHERE CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);
                con.Open();
                object p = cmd.ExecuteScalar();
                if (p != null) price = Convert.ToDecimal(p);
            }

            if (price == 0)
            {
                // Free course -> auto enroll user!
                using (SqlConnection con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(
                        "IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID) " +
                        "INSERT INTO Enrollments (UserID, CourseID, Progress, EnrolledAt) VALUES (@UserID, @CourseID, 0, GETDATE())", con);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@CourseID", CourseId);
                    cmd.ExecuteNonQuery();

                    SqlCommand xp = new SqlCommand(
                        "INSERT INTO XPLogs (UserID, PointsEarned, Reason) VALUES (@UserID, 50, 'Enrolled in a course')", con);
                    xp.Parameters.AddWithValue("@UserID", userId);
                    xp.ExecuteNonQuery();

                    SqlCommand notify = new SqlCommand(
                        "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                        "VALUES (@UserID, 'Enrolled Successfully', 'You enrolled in a new course!', 'course')", con);
                    notify.Parameters.AddWithValue("@UserID", userId);
                    notify.ExecuteNonQuery();
                }

                Response.Redirect("~/CourseDetail.aspx?id=" + CourseId);
            }
            else
            {
                // Paid course -> redirect to payment section
                Response.Redirect("~/Payment.aspx?courseId=" + CourseId);
            }
        }

        private void LoadModules()
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT M.ModuleID, M.Title, M.ContentType, M.Description, M.DurationMins, M.OrderIndex, M.IsPreview, " +
                    "ISNULL(MP.IsCompleted, 0) AS IsCompleted " +
                    "FROM Modules M " +
                    "LEFT JOIN ModuleProgress MP " +
                    "  ON M.ModuleID = MP.ModuleID AND MP.UserID = @UserID " +
                    "WHERE M.CourseID = @CourseID " +
                    "ORDER BY M.OrderIndex", con);
                da.SelectCommand.Parameters.AddWithValue("@CourseID", CourseId);
                da.SelectCommand.Parameters.AddWithValue("@UserID", GetCurrentUserId());

                DataTable dt = new DataTable();
                da.Fill(dt);
                rptModules.DataSource = dt;
                rptModules.DataBind();
            }
        }

        private void LoadProgress()
        {
            int userId = GetCurrentUserId();
            if (userId == 0)
            {
                pnlProgress.Visible = false;
                pnlEnroll.Visible = true;
                return;
            }

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT Progress FROM Enrollments " +
                    "WHERE UserID = @UserID AND CourseID = @CourseID", con);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@CourseID", CourseId);

                con.Open();
                object result = cmd.ExecuteScalar();

                if (result != null)
                {
                    int progress = Convert.ToInt32(result);
                    litProgress.Text = progress.ToString();
                    divProgressFill.Style["width"] = progress + "%";
                    pnlProgress.Visible = true;
                    pnlEnroll.Visible = false; // Hide enroll button if already enrolled
                }
                else
                {
                    pnlProgress.Visible = false;
                    pnlEnroll.Visible = true;
                }
            }
        }
    }
}