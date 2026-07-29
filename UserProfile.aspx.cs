using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class UserProfile : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        public int TargetUserId
        {
            get
            {
                int id;
                if (int.TryParse(Request.QueryString["id"], out id) && id > 0) return id;
                if (int.TryParse(Request.QueryString["userId"], out id) && id > 0) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int userId = TargetUserId;
                if (userId <= 0)
                {
                    pnlNotFound.Visible = true;
                    pnlProfile.Visible = false;
                    return;
                }

                LoadUserProfile(userId);
            }
        }

        private void LoadUserProfile(int userId)
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT FullName, Email, Role, Bio, ProfilePic FROM Users WHERE UserID = @UserID AND IsActive = 1", con);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        string fullName = dr["FullName"].ToString();
                        litFullName.Text = Server.HtmlEncode(fullName);
                        litRole.Text = dr["Role"].ToString();

                        string bio = dr["Bio"] == DBNull.Value ? "" : dr["Bio"].ToString();
                        litBio.Text = string.IsNullOrWhiteSpace(bio)
                            ? "Creative learner at Atelier."
                            : Server.HtmlEncode(bio);

                        string pic = dr["ProfilePic"] == DBNull.Value ? "" : dr["ProfilePic"].ToString();
                        imgAvatar.ImageUrl = string.IsNullOrEmpty(pic) ? "Images/default-avatar.png" : pic;

                        pnlNotFound.Visible = false;
                        pnlProfile.Visible = true;
                    }
                    else
                    {
                        pnlNotFound.Visible = true;
                        pnlProfile.Visible = false;
                        return;
                    }
                }

                // Stats
                SqlCommand cmdXP = new SqlCommand(
                    "SELECT ISNULL(SUM(PointsEarned), 0) FROM XPLogs WHERE UserID = @UserID", con);
                cmdXP.Parameters.AddWithValue("@UserID", userId);
                lblXP.Text = cmdXP.ExecuteScalar().ToString() + " XP";

                SqlCommand cmdBadges = new SqlCommand(
                    "SELECT COUNT(*) FROM UserBadges WHERE UserID = @UserID", con);
                cmdBadges.Parameters.AddWithValue("@UserID", userId);
                int badgeCount = Convert.ToInt32(cmdBadges.ExecuteScalar());
                lblBadges.Text = badgeCount.ToString() + " Badges";

                SqlCommand cmdCourses = new SqlCommand(
                    "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID", con);
                cmdCourses.Parameters.AddWithValue("@UserID", userId);
                int courseCount = Convert.ToInt32(cmdCourses.ExecuteScalar());
                lblCourses.Text = courseCount.ToString() + " Courses";

                // Badges repeater
                SqlDataAdapter daBadges = new SqlDataAdapter(
                    "SELECT UB.EarnedAt, B.BadgeName, B.Description, B.IconURL " +
                    "FROM UserBadges UB " +
                    "JOIN Badges B ON UB.BadgeID = B.BadgeID " +
                    "WHERE UB.UserID = @UserID " +
                    "ORDER BY UB.EarnedAt DESC", con);
                daBadges.SelectCommand.Parameters.AddWithValue("@UserID", userId);
                DataTable dtBadges = new DataTable();
                daBadges.Fill(dtBadges);

                rptBadges.DataSource = dtBadges;
                rptBadges.DataBind();
                pnlNoBadges.Visible = (dtBadges.Rows.Count == 0);

                // Enrolled courses repeater
                SqlDataAdapter daCourses = new SqlDataAdapter(
                    "SELECT C.CourseID, C.Title, CC.CategoryName, C.Thumbnail " +
                    "FROM Enrollments E " +
                    "JOIN Courses C ON E.CourseID = C.CourseID " +
                    "LEFT JOIN CourseCategories CC ON C.CategoryID = CC.CategoryID " +
                    "WHERE E.UserID = @UserID " +
                    "ORDER BY E.EnrolledAt DESC", con);
                daCourses.SelectCommand.Parameters.AddWithValue("@UserID", userId);
                DataTable dtCourses = new DataTable();
                daCourses.Fill(dtCourses);

                rptCourses.DataSource = dtCourses;
                rptCourses.DataBind();
                pnlNoCourses.Visible = (dtCourses.Rows.Count == 0);
            }
        }
    }
}
