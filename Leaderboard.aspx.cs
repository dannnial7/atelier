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

        public int CurrentUserId
        {
            get
            {
                if (Session["UserID"] != null)
                    return Convert.ToInt32(Session["UserID"]);
                if (Session["userID"] != null)
                    return Convert.ToInt32(Session["userID"]);

                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLeaderboard();
            }
        }

        public string GetRankClass(int rank)
        {
            if (rank == 1) return "rank-badge rank-1";
            if (rank == 2) return "rank-badge rank-2";
            if (rank == 3) return "rank-badge rank-3";
            return "rank-badge";
        }

        public string GetRankIcon(int rank)
        {
            return rank.ToString();
        }

        private void LoadLeaderboard()
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT U.UserID, U.FullName, " +
                    "  ISNULL(CAST(U.Bio AS NVARCHAR(MAX)), '') AS Bio, " +
                    "  ISNULL(U.ProfilePic, '') AS ProfilePic, " +
                    "  ISNULL((SELECT SUM(PointsEarned) FROM XPLogs WHERE UserID = U.UserID), 0) AS TotalXP, " +
                    "  (SELECT COUNT(*) FROM UserBadges UB WHERE UB.UserID = U.UserID) AS BadgeCount " +
                    "FROM Users U " +
                    "WHERE U.Role = 'Learner' AND U.IsActive = 1 " +
                    "ORDER BY TotalXP DESC, U.FullName ASC", con);

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

        private void ShowYourStanding(DataTable dt)
        {
            if (CurrentUserId == 0) return;

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt.Rows[i]["UserID"]) == CurrentUserId)
                {
                    lblYourRank.Text = "#" + (i + 1);
                    lblYourXP.Text = dt.Rows[i]["TotalXP"].ToString() + " XP";
                    lblTotalLearners.Text = dt.Rows.Count.ToString();
                    pnlYourRank.Visible = true;
                    return;
                }
            }
        }
    }
}