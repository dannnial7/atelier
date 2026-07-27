using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Atelier
{
    public partial class Leaderboard : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        // Exposed as a public property so the markup can highlight the row
        // belonging to the learner viewing the page.
        public int CurrentUserId
        {
            get
            {
                if (Session["UserID"] != null)
                    return Convert.ToInt32(Session["UserID"]);

                return 2; // TEMPORARY: see Dashboard.aspx.cs
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLeaderboard();
            }
        }

        // The top three ranks are styled differently, so the row's position
        // determines which class the rank badge is given.
        public string GetRankClass(int rank)
        {
            if (rank == 1) return "rank-badge rank-1";
            if (rank == 2) return "rank-badge rank-2";
            if (rank == 3) return "rank-badge rank-3";
            return "rank-badge";
        }

        private void LoadLeaderboard()
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                // Experience points are summed from the log rather than stored
                // against the user, so the ranking always reflects every point
                // that has been awarded. Badge counts come from a subquery so
                // that a learner with no badges still appears, showing zero.
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT U.UserID, U.FullName, " +
                    "  SUM(X.PointsEarned) AS TotalXP, " +
                    "  (SELECT COUNT(*) FROM UserBadges UB " +
                    "     WHERE UB.UserID = U.UserID) AS BadgeCount " +
                    "FROM Users U " +
                    "JOIN XPLogs X ON U.UserID = X.UserID " +
                    "WHERE U.Role = 'Learner' AND U.IsActive = 1 " +
                    "GROUP BY U.UserID, U.FullName " +
                    "ORDER BY TotalXP DESC", con);

                da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                pnlBoard.Visible = false;
                pnlEmpty.Visible = true;
                return;
            }

            rptLeaderboard.DataSource = dt;
            rptLeaderboard.DataBind();

            ShowYourStanding(dt);
        }

        // The learner's own position is read from the same result set rather
        // than queried again, so the two can never disagree.
        private void ShowYourStanding(DataTable dt)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt.Rows[i]["UserID"]) == CurrentUserId)
                {
                    lblYourRank.Text = "#" + (i + 1);
                    lblYourXP.Text = dt.Rows[i]["TotalXP"].ToString();
                    lblTotalLearners.Text = dt.Rows.Count.ToString();
                    pnlYourRank.Visible = true;
                    return;
                }
            }
        }
    }
}