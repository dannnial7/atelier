USE master
GO
ALTER DATABASE AtelierDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE AtelierDatabase
GO
CREATE DATABASE AtelierDatabase
GO
USE AtelierDatabase
GO

-- "Users" is for everyone that has an account only (therefore, no guest role in this section.

CREATE TABLE Users(
UserID INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) NOT NULL, --required field, hence, not null
Email VARCHAR(100) NOT NULL UNIQUE, -- unique func. doesn't allow more than 1 user to have the same email address

PasswordHash VARCHAR(255) NOT NULL,
Role VARCHAR(20) DEFAULT 'Learner',
RegisteredAt DATETIME DEFAULT GETDATE(),
IsActive BIT DEFAULT 1,
ProfilePic VARCHAR(255),
Bio TEXT,
ThemePreferred VARCHAR(10) DEFAULT 'light'
)
GO

-- Course categories table, admin creates and manages

CREATE TABLE CourseCategories(
CategoryID INT PRIMARY KEY IDENTITY,
CategoryName VARCHAR(100) NOT NULL,
Description TEXT, --for course description
IconURL VARCHAR(255),
CreatedAt DATETIME DEFAULT GETDATE()
)
GO

-- Course available, admin creates and manages

CREATE TABLE Courses(
CourseID INT PRIMARY KEY IDENTITY,
Title VARCHAR(200) NOT NULL,
Description TEXT,
CategoryID INT FOREIGN KEY REFERENCES CourseCategories(CategoryID),
Thumbnail VARCHAR(255),
Price DECIMAL(10,2) DEFAULT 0.00,
Difficulty VARCHAR(20) DEFAULT 'Beginner',
IsPublished BIT DEFAULT 0, --If 0, only admin will see the course, if 1, everyone can see
CreatedAt DATETIME DEFAULT GETDATE(),
CreatedBy INT FOREIGN KEY REFERENCES Users(UserID)
)  
GO

--Modules

CREATE TABLE Modules(
ModuleID INT PRIMARY KEY IDENTITY,
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID) ON DELETE CASCADE, -- used "on delete cascade" for all modules in a course to be deleted automatically when admin delete said course.

Title VARCHAR(200) NOT NULL,
ContentType VARCHAR(20),
ContentURL VARCHAR(500),
Description TEXT,
OrderIndex INT,
DurationMins INT,
IsPreview BIT DEFAULT 0 
)

GO
--admin creates and manages, skills earned by learners after they complete a course

CREATE TABLE Skills(
SkillID INT PRIMARY KEY IDENTITY,
SkillName VARCHAR(100) NOT NULL,
SkillCategory VARCHAR(50),
Colour VARCHAR(20) DEFAULT '#4F46E5'
)
GO

--Describes the content of a course

CREATE TABLE CourseSkills(
CourseSkillID INT PRIMARY KEY IDENTITY,
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID) ON DELETE CASCADE,
SkillID INT FOREIGN KEY REFERENCES Skills(SkillID) ON DELETE CASCADE )

GO

--Enrollments

CREATE TABLE Enrollments (
EnrollmentID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID), 
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
EnrolledAt DATETIME DEFAULT GETDATE(),
Progress INT DEFAULT 0, --Progress updates as learners complete the module
CertificateID VARCHAR(50),
CompletedAt DATETIME )

GO

--Payments 
CREATE TABLE Payments(
PaymentID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
Amount DECIMAL(10,2),
PaidAt DATETIME DEFAULT GETDATE(),
Status VARCHAR(20) DEFAULT 'Completed',
Cardlastdigits VARCHAR(4) ) --only last 4 digits of card number

GO

--Module Progress board

CREATE TABLE ModuleProgress(
ProgressID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
ModuleID INT FOREIGN KEY REFERENCES Modules(ModuleID) ON DELETE CASCADE,
IsCompleted BIT DEFAULT 0,
CompletedAt DATETIME )

GO

--Displayed as learner's skills when they complete a coursew

CREATE TABLE UserSkills(
UserSkillID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
TagID INT FOREIGN KEY REFERENCES Skills(SkillID),
EarnAt DATETIME DEFAULT GETDATE(),
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID)
)

GO

--Assessments
CREATE TABLE Assessments(
AssessmentID INT PRIMARY KEY IDENTITY,
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID) ON DELETE CASCADE,
Title VARCHAR(200) NOT NULL,
TimeLimit INT DEFAULT 30, --in minutes
PassMark INT DEFAULT 60,
MaxAttempts INT DEFAULT 3
)

GO

--Questions

CREATE TABLE Questions(
QuestionID INT PRIMARY KEY IDENTITY,
AssessmentID INT FOREIGN KEY REFERENCES Assessments(AssessmentID) ON DELETE CASCADE,
QuestionText TEXT NOT NULL,
QuestionType VARCHAR(20) DEFAULT 'MCQ',
OrderIndex INT,
Marks INT DEFAULT 1
)
GO

--Options for MCQ questions

CREATE TABLE Options(
OptionID INT PRIMARY KEY IDENTITY,
QuestionID INT FOREIGN KEY REFERENCES Questions(QuestionID) ON DELETE CASCADE,
OptionText VARCHAR(500) NOT NULL,
IsCorrect BIT DEFAULT 0 )

GO
--Submissions
CREATE TABLE Submissions(
SubmissionID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
AssessmentID INT FOREIGN KEY REFERENCES Assessments(AssessmentID),
FilreURL VARCHAR(500),
TextResponse TEXT,
SubmittedAt DATETIME DEFAULT GETDATE(),
Status VARCHAR(20) DEFAULT 'Draft', --Optiions = draft, submitted and graded
Grade INT,
Feedback TEXT,
GradedAt DATETIME,
GradedBy INT FOREIGN KEY REFERENCES Users(UserID) )

GO

--Assessments Results, mcq is auto graded, other type of assessments graded by instructors

CREATE TABLE AssessmentsResults(
ResultID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
AssessmentID INT FOREIGN KEY REFERENCES Assessments(AssessmentID),
Score INT,
Passed BIT,
TakenAt DATETIME DEFAULT GETDATE(),
AttemptNumber INT )

GO

--leaners take notes, updated every time they save their notes, allowed only 1 note per module

CREATE TABLE NOTES(
NoteID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
ModuleID INT FOREIGN KEY REFERENCES Modules(ModuleID) ON DELETE CASCADE,
NoteText TEXT,
UpdatedAt DATETIME DEFAULT GETDATE(),
) 
GO

--Forum = discussion threads, managed by admin

CREATE TABLE Forum(
ForumID INT PRIMARY KEY IDENTITY,
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
UserID INT FOREIGN KEY REFERENCES Users(UserID),
Title VARCHAR(200) NOT NULL,
Body TEXT,
CreatedAt DATETIME DEFAULT GETDATE(),
Pinned BIT DEFAULT 0,
Locked BIT DEFAULT 0,
ViewCount INT DEFAULT 0 ) --increases each time someone open the thread

GO

--Forum Replies

CREATE TABLE ForumReplies(
ReplyID INT PRIMARY KEY IDENTITY,
ForumID INT FOREIGN KEY REFERENCES Forum(ForumID) ON DELETE CASCADE,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
Body TEXT NOT NULL,
PostedAt DATETIME DEFAULT GETDATE(),
IsReported BIT DEFAULT 0,
ReportedBy INT FOREIGN KEY REFERENCES Users(UserID),
ReportReason VARCHAR(200)
)
GO

--Notifications

CREATE TABLE Notifications(
NotificationID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
Title VARCHAR(200),
Body TEXT,
Type VARCHAR(50), --notif type = announcements, forum, badge, grade
IsRead BIT DEFAULT 0,
CreatedAt DATETIME DEFAULT GETDATE(),
LinkURL VARCHAR(500) --link to go to notif section

)
GO

--Badges (Acts as a learner's achievement)

CREATE TABLE Badges(
BadgeID INT PRIMARY KEY IDENTITY,
BadgeName VARCHAR(100) NOT NULL,
Description VARCHAR(500),
IconURL VARCHAR(255),
Condition VARCHAR(200)
)
GO

--User badges 

CREATE TABLE UserBadges(
UserBadgeID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
BadgeID INT FOREIGN KEY REFERENCES Badges(BadgeID),
EarnedAt DATETIME DEFAULT GETDATE()
)
GO

--XP logs (Experienced Points, records all XP points earned by leareners)

CREATE TABLE XPLogs(
LogID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
PointsEarned INT,
Reason VARCHAR(200),
EarnedAt DATETIME DEFAULT GETDATE()
)
GO

--Portfolio items = contains learner submitted work in the gallery, can be viewed by guests

CREATE TABLE PortfolioItems(
PortfolioID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
Title VARCHAR(200) NOT NULL,
Description TEXT,
FileURL VARCHAR(500),
SubmittedAt DATETIME DEFAULT GETDATE(),
LikeCountT INT DEFAULT 0,
IsFeatured BIT DEFAULT 0 ) 

GO

--Reviews

CREATE TABLE Reviews(
ReviewID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
Rating INT,
ReviewText TEXT,
CreatedAt DATETIME DEFAULT GETDATE(),
IsVerified BIT DEFAULT 0,

CONSTRAINT CHK_Rating CHECK (Rating >= 1 AND Rating <= 5)


)
GO

--Monthly challenge 

CREATE TABLE MonthlyChallenge(
ChallengeID INT PRIMARY KEY IDENTITY,
Theme VARCHAR(200) NOT NULL,
Description TEXT,
StartDate DATETIME,
EndDate DATETIME,

CreatedBy INT FOREIGN KEY REFERENCES Users(UserID),
IsActive BIT DEFAULT 1 )
GO

--Challenge entires

CREATE TABLE ChallengeEntries(
EntryID INT PRIMARY KEY IDENTITY,
ChallengeID INT FOREIGN KEY REFERENCES MonthlyChallenge(ChallengeID),
UserID INT FOREIGN KEY REFERENCES Users(UserID),
Title VARCHAR(200),
FileURL VARCHAR(500),
SubmittedAt DATETIME DEFAULT GETDATE(),
VoteCount INT DEFAULT 0,
IsPinned BIT DEFAULT 0
) 
GO

-- Challenge vote

CREATE TABLE ChallengeVote(
VoteID INT PRIMARY KEY IDENTITY,
EntryID INT FOREIGN KEY REFERENCES ChallengeEntries(EntryID) ON DELETE CASCADE,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
VotedAt DATETIME DEFAULT GETDATE()
)
GO

-- GUEST inquiries

CREATE TABLE GuestInquiries(
InquiryID INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) NOT NULL,
Email VARCHAR(100) NOT NULL,
Subject VARCHAR(200),
Message TEXT NOT NULL,
SubmittedAt DATETIME DEFAULT GETDATE(),
Status VARCHAR(20) DEFAULT 'Pending',

IsWithdrawn BIT DEFAULT 0,
AdminResponse TEXT )
GO

-- FAQs

CREATE TABLE FAQs(
FAQID INT PRIMARY KEY IDENTITY,
Question VARCHAR(500) NOT NULL,
Answer TEXT NOT NULL,
OrderIndex INT,
IsActive BIT DEFAULT 1
)
GO

--password token, created when suer forgets pwd

CREATE TABLE PasswordResetToken(
TokenID INT PRIMARY KEY IDENTITY,
UserID INT FOREIGN KEY REFERENCES Users(UserID),
Token VARCHAR(100) NOT NULL,
CreatedAt DATETIME DEFAULT GETDATE(),
IsUsed bit default 0
)
GO


--DATA

--Course categories

INSERT INTO CourseCategories (CategoryName, Description)
values ('Visual Arts', 'Drawing, painting and digital illustration'), ('Digital Arts', '3D Modelling, Game Art and Visual Effects'), ('Photography', 'Camera Technqiues, lighting and editing'), ('Film & Video', 'Film making, video editing and storytelling'),
('Creative Writing', 'Poetry, Storytelling and Fiction Writing')

INSERT INTO Users (FullName, Email, PasswordHash, Role)
VALUES ('Admin User', 'admin@atelier.com', '$2a$11$wcpeOpDEjSiDRpxwt.HLdumLk6uFFOrUiyyPIpZSvplYSpvi03WcK', 'Admin'), 
('Dibyajoti Roy', 'Roy@atelier.com', '$2a$11$geHeVYIqmdjh51RZTBLBm.EXUNvGLXFrWMxHcn7Zb80UXDgbDooVu', 'Learner'), 
('Ethan Hill', 'Ethan@atelier.com', '$2a$11$6gnPPj3POQWRPUcMN8D9ROyRPRAei8RHHJiw/ljkwM1xI0py.Nc3C', 'Learner'), 
('Sarah Chen', 'sarah@atelier.com', '$2a$11$98a1ya.UEIRTzxQapFq0FuGp1bi3g.ssYIKQp33yruiVptYR1bWEO', 'Learner'), 
('Daphne kim', 'Kim@atelier.com', '$2a$11$hldqzaH5vqbeUNM8LJYgI./FWyLgeG1xBho2bwePCs.uFTN/OhrzO', 'Learner')


INSERT INTO Courses (Title, Description, CategoryID, Price, Difficulty, IsPublished, CreatedBy, Thumbnail) --Category id: Visual arts=1, Photography = 3, Digital Art=2, Film and video=4, creative writing=5)

VALUES ('Visual Arts - Figure Drawing Fundamentals', 'Learn the foundations of figure drawing. Master proportion, gesture and form through structured lessons and exercises.', 1, 0.00, 'Beginner', 1, 1, '~/Images/Courses/Visual-Arts.jpg'),
('Advanced Digital Arts', 'Master advanced digital art techniques and explore creative production used in gaming and digital media industries.', 2, 79.99, 'Advanced', 1, 1, '~/Images/Courses/Digital-Arts.jpg'),
('Portrait Photography Masterclass', 'Capture gorgeous portraits with any camera. Learn lighting and composition: Detailed Course Overview', 3, 49.99, 'Intermediate', 1, 1, '~/Images/Courses/photography.jpg'),  
('Intro to Film making', 'Learn visual storytelling from scratch. Cover shooting techniques and basic editing principles.', 4, 0.00, 'Beginner', 1, 1, '~/Images/Courses/Filmmaking.jpg'), 
('Creative Writing', 'Develop storytelling, Poetry, and Fiction Writing skills.', 5, 0.00, 'Beginner', 1, 1, '~/Images/Courses/Creative-Writing.jpg')

INSERT INTO Modules( CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
VALUES 
--1 course (3 modules), only 1st 2 modules will be available for guest to see, therefore, set to 1)


--Course 1: Visual arts

(1, 'Understanding Proportions', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'In this section, you will learn how to apply correct figure proportions in your drawings.', 1, 20, 1), 

(1, 'Figure Drawing Fundamentals', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/gpH8T2CRlLI?si=qgGFcvHY2oVVVQn4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>'
,'In this video, you will learn and understand about the fundamental techniques to master figure drawing.', 2, 44, 0),

--Course2: Digital Arts

(2, 'Advanced Digital art and 3D Modelling', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/Iyf-Zp3CRLg?si=a-2QDYABqekaDWfF" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>'
, 'In this module, you will learn the fundamentals of 3D modelling, including creating, shaping, and refining digital objects for animation, games, and visual media.', 1, 180, 1), 

(2, 'Game Art', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/q8NF6guWgNw?si=oCIf4iGwXQrWThXF" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'In this module, you will learn about game art and how to create engaging game assets.', 2, 12, 1), 

(2, 'Visual Effects Masterclass', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/uRdfvpQ5rcQ?si=EOLiqf_CEC3uudA5" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'Learn visual effects that enhance immersive digital experiences', 3, 7, 0),

--Course3: photography

(3, 'Portrait Photography Masterclass', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/IU9VvlWu0Ug?si=C-77yra0rq9WLFUu" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> '
, 'In this module, you will learn advanced photography techniques, creative composition, and professional lighting methods to create compelling and visually impactful photographs.', 1, 120, 1), 

(3, 'Editing your photos in Lightroom', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/qlKR_cEIORY?si=I8w-CmPVJf9btTZp" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'Learn how editing allows you to refine your vision and correct any technical imperfections', 2, 135, 1),

(3, 'Street and Documentary Photography', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/bLMjr3YQMMQ?si=AttiCi8eh9TcPw28" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'In this module, you will learn how to capture real-life stories and develop them into visual narratives', 3, 95, 0),

--Course 4: Film making

(4, 'Intro to Film making', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/8QCK_qEp_PI?si=6YED5PI3Y-YqcpOF" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'Learn the basics and fundamental parts of film making.', 1, 9, 1), 

(4, 'Basic Video Editing Principles', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/zK-S_ZCdeQE?si=ng7Xyf3_Jet58hEy" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'Video editing is the process of selecting, arranging, and refining footage to tell a story. 
Go through the video to understand the basics and for your first editing project, take 5 minutes of raw footage and edit it down to a 60 second sequence that tells a clear story with a beginning, middle, and end.', 
2, 15, 1), 

(4, 'The road to storytelling in Filmmaking', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/BxrkyfSDrSQ?si=ZoVUS1Vio1ErZEEg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'Learn the principles of visual storytelling, script development and its techniques to create compelling cinematic narratives', 3, 54, 0),

--Course 5: creative writing

(5, 'Creative Writing: Storytelling', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/tcgIQ_ld0Ls?si=bdcW4IVk_eg_9zX1" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'In this module, you will learn to express ideas creatively through storytelling while developing your unique narrative skills.', 1, 10, 1), 

(5, 'The best way to learn Fiction Writing', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/wDhU9fOAhiA?si=E1K3Az45Nw0Rc3Qo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>', 
'In this module, you will learn to create compelling characters, plots, and stories through the art of fiction writing.', 2, 150, 0),

-- Additional PDF materials across courses
(2, 'Digital Art Workflow & Industry Toolset Guide', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Comprehensive PDF guide covering digital artwork pipelines, layer management, color spaces, and essential software shortcut cheatsheets.', 4, 25, 1),
(3, 'Exposure Triangle & Camera Cheat Sheet', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Downloadable PDF reference guide detailing Aperture (f-stop), Shutter Speed, ISO combinations, focal lengths, and depth-of-field charts.', 4, 15, 1),
(4, 'Film Production Handbook & Shot Types', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'PDF guide covering camera coverage, shot types (Extreme Long, Medium, Close-Up), camera movements, and call-sheet templates.', 4, 20, 1),
(5, 'Character Development & Worldbuilding Manual', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Comprehensive PDF workbooks for creating character character arcs, desire vs need matrices, and immersive worldbuilding rules.', 3, 20, 1)




INSERT INTO Assessments(CourseID, Title, TimeLimit, PassMark, MaxAttempts)
VALUES (1, 'Figure Drawing Fundamentals Quiz', 30, 60, 3), (2, 'Advanced Digital Arts Quiz', 30, 60, 3), (3, 'Portrait Photography Masterclass', 30, 60, 3), (4, 'Intro to Film Making', 30, 60, 3),
(5, 'Creative Writing', 30, 60,3)

INSERT INTO Questions(AssessmentID, QuestionText, QuestionType, OrderIndex, Marks)
VALUES 

--Course 1 Quiz

(1, 'What is the standard number of head lengths used to measure the human body in figure drawing?', 'MCQ', 1, 1), (1, 'Which type of line captures the overall movement and energy of a pose?', 'MCQ', 2, 1),
(1, 'What is the recommended time limit for a single gesture drawing practice session?', 'MCQ', 3, 1),

--Course 2

(2, 'What is the primary purpose of 3D Modelling?', 'MCQ', 1, 1), (2, 'Which of the following is considered as a game asset?', 'MCQ', 2, 1), (2, 'What technique combine multiple images into one scene?', 'MCQ', 3, 1),

--Course 3

(3, 'What does ISO control in photography?', 'MCQ', 1, 1), (3, 'Soft lightning generally creates: ',  'MCQ', 2, 1), (3, 'Documentary photography aims to: ', 'MCQ', 3, 1),

--Course 4
(4, 'Who is typically the central character in a story?', 'MCQ', 1, 1), (4, 'What is a shot in film making?', 'MCQ', 2, 1), (4, 'What does continuity editing helps maintain?', 'MCQ', 3, 1),

--Course 5
(5, 'What is a metaphor?', 'MCQ', 1, 1), (5, 'Why is chacraters important?', 'MCQ', 2, 1), (5, 'What is dialogue in fiction used for?', 'MCQ', 3, 1)

--The mcq options (1 question has 4 options, one of which is the correct answer)

INSERT INTO Options(QuestionID, OptionText, IsCorrect) 
VALUES

--COUrse 1 no.1
(1, '5 heads', 0), (1, '6 heads', 0), (1, '7.5 heads', 1), (1, '9 heads', 0),

--no.2
(2, 'Contour line', 0), (2, 'gesture line', 1), (2, 'Cross hatching line', 0), (2, 'Outline', 0),

--no.3
(3, '5 minutes', 0), (3, '10 minutes', 0), (3, '30 to 60 seconds', 1), (3, '2 to 3 minutes', 0),

--Course 2

(4, 'vertex', 1), (4, 'Timeline', 0), (4, 'Frame rate', 0), (4, 'Shutter spped', 0), --no.1 
(5, 'Character Model', 1), (5, 'Keyboard', 0), (5, 'Broswer', 0), (5, 'Creating soundtracks', 0), --no.2
(6, 'Sculpting', 0), (6, 'Compositing', 1), (6, 'Cropping', 0), (6, 'Framing', 0), --no.3

--Course 3

(7, 'Image Sharpeness', 0), (7, 'Sensor sensitivity of light', 1), (7, 'Lens size', 0), (7, 'File format', 0),
(8, 'Harsh shadows', 0), (8, 'Strong contrast', 0), (8, 'Gentle shadows', 1), (8, 'Dark backgrounds', 0),
(9, 'Create fictional scenes', 0), (9, 'Record and tell real life stories', 1), (9, 'Sell products', 0), (9, 'Design logos', 0)


INSERT INTO Assessments(CourseID, Title, TimeLimit, PassMark, MaxAttempts)
VALUES 
(1, 'Figure Drawing Quiz', 30, 60, 3),
(2, 'Digital Arts Masterclass Quiz', 40, 70, 3),
(3, 'Portrait Photography Quiz', 25, 60, 3),
(4, 'Intro to Filmmaking Quiz', 30, 60, 3),
(5, 'Creative Writing Quiz', 30, 60, 3)

INSERT INTO Questions(AssessmentID, QuestionText, QuestionType, OrderIndex, Marks)
VALUES 
--Course 1
(1, 'What is the primary goal of figure drawing?', 'MCQ', 1, 1), (1, 'What technique is used to capture line of action in gesture drawing?', 'MCQ', 2, 1), (1, 'How many heads high is a standard proportional human body model?', 'MCQ', 3, 1),
--Course 2
(2, 'What does subsurface scattering simulate in digital rendering?', 'MCQ', 1, 1), (2, 'Which map type adds fine geometric depth without high polygon counts?', 'MCQ', 2, 1), (2, 'What is primary color correction in digital painting?', 'MCQ', 3, 1),
--Course 3
(3, 'Which aperture setting creates a shallower depth of field?', 'MCQ', 1, 1), (3, 'What is the main purpose of a fill light in portraits?', 'MCQ', 2, 1), (3, 'What does ISO setting control on a digital camera?', 'MCQ', 3, 1),
--Course 4
(4, 'What camera angle makes a subject appear powerful?', 'MCQ', 1, 1), (4, 'What is Foley in film production?', 'MCQ', 2, 1), (4, 'What frame rate is standard for cinema projection?', 'MCQ', 3, 1),
--Course 5
(5, 'What is a metaphor in creative writing?', 'MCQ', 1, 1), (5, 'What is the purpose of an inciting incident?', 'MCQ', 2, 1), (5, 'What is subtext in character dialogue?', 'MCQ', 3, 1)

INSERT INTO Options(QuestionID, OptionText, IsCorrect)
VALUES 
--Course 1
(1, 'Understand body structure and movement', 1), (1, 'Trace photos precisely', 0), (1, 'Paint realistic skin tones', 0), (1, 'Design clothing', 0),
(2, 'Quick fluid strokes capturing movement', 1), (2, 'Heavy crosshatching', 0), (2, 'Grid measuring', 0), (2, 'Digital blurring', 0),
(3, '7.5 to 8 heads', 1), (3, '4 heads', 0), (3, '12 heads', 0), (3, '5 heads', 0),
--Course 2
(4, 'Light penetrating translucent surfaces like skin', 1), (4, 'Lens flare shadows', 0), (4, 'File compression artifacting', 0), (4, 'Background defocusing', 0),
(5, 'Normal map / Displacement map', 1), (5, 'Specular map', 0), (5, 'Roughness map', 0), (5, 'Ambient occlusion map', 0),
(6, 'Adjusting overall tonal balance across the image', 1), (6, 'Cropping the canvas', 0), (6, 'Adding watermarks', 0), (6, 'Resizing brush tips', 0),
--Course 3
(7, 'f/1.8', 1), (7, 'f/16', 0), (7, 'f/22', 0), (7, 'f/11', 0),
(8, 'Softens dark shadows created by the key light', 1), (8, 'Blinds the subject', 0), (8, 'Changes background color', 0), (8, 'Replaces camera flash', 0),
(9, 'Sensor sensitivity to light', 1), (9, 'Shutter speed duration', 0), (9, 'Lens focal length', 0), (9, 'White balance tint', 0),
--Course 4
(10, 'Low angle shot looking up', 1), (10, 'High angle shot looking down', 0), (10, 'Bird eye view', 0), (10, 'Dutch tilt', 0),
(11, 'Custom sound effects created for post-production', 1), (11, 'Director commentary', 0), (11, 'Actor auditions', 0), (11, 'Film script draft', 0),
(12, '24 fps', 1), (12, '60 fps', 0), (12, '120 fps', 0), (12, '15 fps', 0),
--Course 5
(13, 'Direct comparison using like or as', 1), (13, 'camera movement', 0), (13, 'video transistion', 0), (13, 'sound effect', 0),
(14, 'Drive the story forward', 1), (14, 'Edit the manuscript', 0), (14, 'design cover', 0), (14, 'Manage publishing', 0),
(15, 'Unspoken meaning behind character words', 1), (15, 'Adjust lightning', 0), (15, 'Create animations', 0), (15, 'Edit photos', 0)


INSERT INTO Badges(BadgeName, Description, IconURL, Condition)
VALUES
('First steps', 'Complete your first module', '~/Images/Badges/first-steps.png', 'Complete 1 module'), 
('Quiz Ace', 'Score 100% score on a quiz', '~/Images/Badges/quiz-ace.png', 'Get 100% score on a quiz'), 
('On a roll', 'Log in 7 days in a row', '~/Images/Badges/on-a-roll.png', 'Maintain a 7 day login streak'),
('Graduate', 'Complete your first course', '~/Images/Badges/graduate.png', 'Complete all modules and pass the quiz'), 
('Social Butterfly', 'Post 5 times in the forum', '~/Images/Badges/social-butterfly.png', 'Post or reply 5 times in the forum'), 
('Creative Champion', 'Win a monthly Challenge', '~/Images/Badges/creative-champion.png', 'Have your entry at the top!')

INSERT INTO FAQs(Question, Answer, OrderIndex)
VALUES
('Is Atelier free to use?', 'Atelier is free to brosw and register. Individual courses are available at different price points. All prices are displayed on the course catalogue.', 1),
('Can I access courses on my phone?', 'Yes, the Atelier platform is fully responsive and works on all modern mobile browser. Simply open your phone browser and visit the Atelier website', 2),
('What courses does Atelier offer?', 'Atelier currently offers courses across six creative disciplines, namely Visual Arts, Digital Arts, Photography, Film & Video, Creative Writing, and Music. Browse the full catalogue regularly to see new courses introduced by the Atelier team.', 3),
('How do I get my completion certificate?', 'Complete all modules in a course and pass the final assessment with a score above the passing mark. Your certificate will automatically be generated and available for download from your dashboard.', 4),
('Can I retake a quiz if I fail?', 'Yes, you can retake each quiz up to 3 times. Your best score will be used for your certificate.', 5),
('How do I enroll in a course?', 'Browse the course catalogue, select any course that interests you, and click the Enroll button. Free courses will enroll you immediately, while paid courses will direct you to the payment page.', 6),
('How many courses can I enroll in at once?', 'There is no limit to how many courses you can enroll in simultaneously', 7),
('How do I earn XP and badges?', 'Atelier features a rewards system where you earn XP Points and achievement badges as you learn. Visit your dashboard to see your current XP level and progress.', 8),
('Who creates courses on Atelier?', 'All courses on Atelier are created and managed by its administration team. Course content is carefully made and chosen to ensure quality and relevance to the disciplines covered on the platform', 9),
('What should I do if I forgot my password?', 'On the login page, click the Forgot Password link and enter your registered email address. You will receive a password reset token. Enter the token on the reset page to create a new password.', 10),
('How do I contact Atelier support?', 'You can reach the Atelier support team through the General Inquiry form on the Contact Page.', 11)


--Added a new course category & additional courses

USE AtelierDatabase

INSERT INTO CourseCategories(CategoryName, Description)
VALUES
('Music', 'Music Production & Instrument Skills Performance')

INSERT INTO Courses(Title, Description, CategoryID, Price, Difficulty, IsPublished, CreatedBy, Thumbnail)
VALUES 
('Music Production Fundamentals', 'Learn the fundamentals of music production from beat making to mixing!', 6, 0.00, 'Beginner', 1, 1, '~/Images/Courses/music.jpg')

INSERT INTO Modules(CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
VALUES
(6, 'Introduction to Music', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/6CFP9DF706s?si=T_hpvunRCXsmuwy3" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>',
'In this module, you will learn about music theory to kickstart your journey.', 1, 23, 1), 
(6, 'Understanding DAW' , 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/uYoUvGgAWeg?si=rTM3Ocb7AfeBb-eE" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>',
'Learn how to manage the Digital Audio Workstation, the software used to record, edit, and produce music.', 2, 10, 1),
(6, 'Beat Making Basics', 'video', '<iframe width="560" height="315" src="https://www.youtube.com/embed/gvE7Ak3Axg4?si=2DJFsOT1Tkf3HPlH" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>',
'Learn how to create your first beat in a jiffy!', 3, 6, 0)

INSERT INTO Assessments(CourseID, Title, TimeLimit, PassMark, MaxAttempts)
VALUES
(6, 'Music Production Fundamentals Quiz', 30, 60, 3)

INSERT INTO Questions(AssessmentID, QuestionText, QuestionType, OrderIndex, Marks)
VALUES
(6, 'What does mixing in music production involves?', 'MCQ', 1, 1), (6, 'What does DAW stand for in music production?', 'MCQ', 2, 1), (6, 'What is a MIDI in music production?', 'MCQ', 3, 1)

INSERT INTO Options(QuestionID, OptionText, IsCorrect)
VALUES
(16, 'Balancing and adjusting audio tracks', 1), (16, 'Writing lyrics', 0), (16, 'Designing album covers', 0), (16, 'Tuning instruments', 0),
(17, 'Digital Audio Writer', 0), (17, 'Digital Audio Workspace', 1), (17, 'Dynamic Audio Workstation', 0), (17, 'Direct Audio Workstation', 0),
(18, 'Musical Instrument Digital Interface', 1), (18, 'Musical Industry Digital Integration', 0), (18, 'Musical Input Device Interface', 0), (18, 'Multi Instrument Data Input', 0)