using System;
using System.Configuration;
using System.Data.SqlClient;

namespace Atelier
{
    public static class BadgeHelper
    {
        private static string ConnStr =>
            ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        public static void EvaluateBadges(int userId)
        {
            if (userId <= 0) return;

            using (SqlConnection con = new SqlConnection(ConnStr))
            {
                con.Open();

                // 1. BadgeID 1: First steps ("Complete 1 module")
                CheckAndAward(con, userId, 1,
                    "SELECT COUNT(*) FROM ModuleProgress WHERE UserID = @UserID AND IsCompleted = 1",
                    cnt => cnt >= 1);

                // 2. BadgeID 2: Quiz Ace ("Get 100% score on a quiz")
                CheckAndAward(con, userId, 2,
                    "SELECT COUNT(*) FROM AssessmentsResults WHERE UserID = @UserID AND Score >= 100",
                    cnt => cnt >= 1);

                // 3. BadgeID 3: On a roll ("Maintain a 7 day login streak")
                CheckAndAward(con, userId, 3,
                    "SELECT COUNT(DISTINCT CAST(EarnedAt AS DATE)) FROM XPLogs WHERE UserID = @UserID",
                    cnt => cnt >= 7);

                // 4. BadgeID 4: Graduate ("Complete all modules and pass the quiz")
                CheckAndAward(con, userId, 4,
                    "SELECT COUNT(*) FROM Enrollments E " +
                    "WHERE E.UserID = @UserID AND E.Progress >= 100 " +
                    "AND EXISTS (SELECT 1 FROM AssessmentsResults AR JOIN Assessments A ON AR.AssessmentID = A.AssessmentID WHERE A.CourseID = E.CourseID AND AR.UserID = @UserID AND AR.Passed = 1)",
                    cnt => cnt >= 1);

                // 5. BadgeID 5: Social Butterfly ("Post or reply 5 times in the forum")
                CheckAndAward(con, userId, 5,
                    "SELECT (SELECT COUNT(*) FROM Forum WHERE UserID = @UserID) + (SELECT COUNT(*) FROM ForumReplies WHERE UserID = @UserID)",
                    cnt => cnt >= 5);

                // 6. BadgeID 6: Creative Champion ("Have your entry at the top!")
                CheckAndAward(con, userId, 6,
                    "SELECT COUNT(*) FROM PortfolioItems WHERE UserID = @UserID AND (IsFeatured = 1 OR LikeCountT > 0)",
                    cnt => cnt >= 1);
            }
        }

        private static void CheckAndAward(SqlConnection con, int userId, int badgeId, string query, Func<int, bool> condition)
        {
            // Check if badge is already awarded
            SqlCommand checkAlready = new SqlCommand(
                "SELECT COUNT(*) FROM UserBadges WHERE UserID = @UserID AND BadgeID = @BadgeID", con);
            checkAlready.Parameters.AddWithValue("@UserID", userId);
            checkAlready.Parameters.AddWithValue("@BadgeID", badgeId);

            int existing = Convert.ToInt32(checkAlready.ExecuteScalar());
            if (existing > 0) return;

            // Check requirement against user activity
            SqlCommand checkCond = new SqlCommand(query, con);
            checkCond.Parameters.AddWithValue("@UserID", userId);

            int val = Convert.ToInt32(checkCond.ExecuteScalar());
            if (condition(val))
            {
                // Verify badge exists in dbo.Badges table
                SqlCommand checkBadgeDef = new SqlCommand(
                    "SELECT BadgeName, Description FROM Badges WHERE BadgeID = @BadgeID", con);
                checkBadgeDef.Parameters.AddWithValue("@BadgeID", badgeId);

                using (SqlDataReader dr = checkBadgeDef.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        string name = dr["BadgeName"].ToString();
                        string desc = dr["Description"].ToString();
                        dr.Close();

                        // Award badge based on dbo.Badges
                        SqlCommand award = new SqlCommand(
                            "INSERT INTO UserBadges (UserID, BadgeID, EarnedAt) VALUES (@UserID, @BadgeID, GETDATE())", con);
                        award.Parameters.AddWithValue("@UserID", userId);
                        award.Parameters.AddWithValue("@BadgeID", badgeId);
                        award.ExecuteNonQuery();

                        // Notify user
                        SqlCommand notify = new SqlCommand(
                            "INSERT INTO Notifications (UserID, Title, Body, Type) " +
                            "VALUES (@UserID, 'New Badge Earned!', @Body, 'badge')", con);
                        notify.Parameters.AddWithValue("@UserID", userId);
                        notify.Parameters.AddWithValue("@Body", "Congratulations! You earned the '" + name + "' badge (" + desc + ").");
                        notify.ExecuteNonQuery();
                    }
                    else
                    {
                        dr.Close();
                    }
                }
            }
        }
    }
}
