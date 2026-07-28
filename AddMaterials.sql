USE AtelierDatabase;
GO

-- Course 2: Advanced Digital Arts
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 2 AND Title = 'Digital Art Workflow & Industry Toolset Guide')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (2, 'Digital Art Workflow & Industry Toolset Guide', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Comprehensive PDF guide covering digital artwork pipelines, layer management, color spaces, and essential software shortcut cheatsheets.', 4, 25, 1),
    (2, 'Principles of 3D Pipeline & Texturing', 'text', NULL, 'Lesson: 3D Graphics & Production Pipeline

The 3D production pipeline is the structured process used by game studios and VFX visualizers to turn concept art into fully rendered digital assets.

1. Modeling & Topology: Creating low-poly and high-poly geometry using clean edge loops.
2. UV Unwrapping: Flattening 3D geometry onto 2D texture maps to avoid texture stretching.
3. Texturing & PBR Materials: Applying Physically Based Rendering (PBR) maps (Albedo, Roughness, Normal, Metallic) for lifelike surface responses.
4. Lighting & Rendering: Setting up three-point lighting, HDRI environmental maps, and ray-tracing render engines.

Assignment: Draft a text breakdown of your planned 3D scene asset list and identify required texture maps.', 5, 30, 0);
END

-- Course 3: Portrait Photography Masterclass
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 3 AND Title = 'Exposure Triangle & Camera Cheat Sheet')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (3, 'Exposure Triangle & Camera Cheat Sheet', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Downloadable PDF reference guide detailing Aperture (f-stop), Shutter Speed, ISO combinations, focal lengths, and depth-of-field charts.', 4, 15, 1),
    (3, 'Mastering Studio Lighting & Portrait Posing', 'text', NULL, 'Lesson: Studio Lighting & Posing Guide

Creating compelling portraiture requires an understanding of light behavior and subject interaction.

Key Lighting Setups:
- Rembrandt Lighting: Characterized by a small triangle of light on the subject shadowed cheek.
- Butterfly (Paramount) Lighting: Placed high directly above the camera to produce a shadow under the nose.
- Rim / Hair Light: Positioned behind the subject to separate them cleanly from the background.

Posing Techniques:
- Directing head angles, shoulder alignment, and micro-expressions.
- Creating triangle geometry with arms and posture to add dynamic energy to portraits.', 5, 20, 0);
END

-- Course 4: Intro to Film making
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 4 AND Title = 'Film Production Handbook & Shot Types')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (4, 'Film Production Handbook & Shot Types', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'PDF guide covering camera coverage, shot types (Extreme Long, Medium, Close-Up), camera movements (Pan, Tilt, Dolly), and call-sheet templates.', 4, 20, 1),
    (4, 'Screenplay Structure & Storyboarding Basics', 'text', NULL, 'Lesson: Screenplay Formatting & Storyboarding

Visual storytelling begins with a structured screenplay and storyboard.

1. Three-Act Narrative Structure:
- Act I (Setup): Inciting incident and character introduction.
- Act II (Confrontation): Rising action, obstacles, and the midpoint plot twist.
- Act III (Resolution): Climax and thematic resolution.

2. Screenplay Formatting:
- Scene Headings (EXT. / INT. - LOCATION - DAY/NIGHT).
- Action blocks written in active present tense.
- Character name centered above dialogue.

3. Storyboarding: Drawing thumbnail panels with camera direction arrows (zoom, track, pan) to pre-visualize shot lists before production day.', 5, 25, 0);
END

-- Course 5: Creative Writing
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 5 AND Title = 'Character Development & Worldbuilding Manual')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (5, 'Character Development & Worldbuilding Manual', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Comprehensive PDF workbooks for creating character character arcs, desire vs need matrices, and immersive worldbuilding rules.', 4, 20, 1),
    (5, 'Narrative Arc & Dialogue Crafting Essentials', 'text', NULL, 'Lesson: Crafting Subtext & Dynamic Dialogue

Great dialogue accomplishes multiple goals at once: advancing plot, revealing character identity, and carrying subtext.

Dialogue Best Practices:
1. Avoid On-the-Nose Writing: Characters rarely state their exact feelings directly; let actions and hesitation carry meaning.
2. Distinct Voice & Cadence: Give characters unique vocabulary, sentence lengths, and speech patterns.
3. Pacing with Action Tags: Interspersed beats (e.g. pouring a cup of coffee) anchor conversations in physical reality.

Exercise: Write a 1-page scene where two characters argue about a mundane object, but the underlying subtext reveals a secret conflict.', 5, 30, 0);
END

-- Course 6: Music Production Fundamentals
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 6 AND Title = 'Digital Audio Workstation Reference Guide')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (6, 'Digital Audio Workstation Reference Guide', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Essential PDF guide to DAW signal flow, VST plugin routing, EQ frequencies, and audio compression ratios.', 4, 25, 1),
    (6, 'Music Theory Essentials & Audio Mixing Principles', 'text', NULL, 'Lesson: Fundamentals of Audio Mixing & Frequency Balance

Mixing turns individual recorded audio tracks into a unified, balanced stereo master.

Key Mixing Pillars:
1. Volume Balancing & Panning: Placing instruments across the soundstage (Left, Center, Right) to build width and clarity.
2. Frequency Sculpting (EQ): High-pass filtering unneeded low frequencies to prevent muddy bass.
3. Dynamic Control (Compression): Taming peaks and smoothing vocal or drum levels.
4. Spatial Effects (Reverb & Delay): Adding depth and ambience to position sounds further back or up front.', 5, 35, 0);
END

-- Course 7: Intermediate Digital Illustration
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 7 AND Title = 'Digital Brush Settings & Color Theory Manual')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (7, 'Digital Brush Settings & Color Theory Manual', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Downloadable PDF covering brush engine dynamics, color harmony (complementary, split-complementary), and digital palette construction.', 3, 20, 1),
    (7, 'Composition, Lighting, and Shading Techniques', 'text', NULL, 'Lesson: Visual Hierarchy & Focal Point Design

A strong illustration guides the viewer eye straight to the intended story element.

1. Focal Point Placement: Use rule of thirds, contrast, and leading lines.
2. Value Structure: Establishing distinct light, midtone, and shadow values before adding color.
3. Ambient Occlusion & Form Shadows: Soft vs hard shadows based on light source distance and surface curves.', 4, 30, 0);
END

-- Course 8: Cinematography & Lighting Masterclass
IF NOT EXISTS (SELECT 1 FROM Modules WHERE CourseID = 8 AND Title = 'Cinema Lighting Diagrams & Technical Cheat Sheet')
BEGIN
    INSERT INTO Modules (CourseID, Title, ContentType, ContentURL, Description, OrderIndex, DurationMins, IsPreview)
    VALUES 
    (8, 'Cinema Lighting Diagrams & Technical Cheat Sheet', 'pdf', 'https://catalogimages.wiley.com/images/db/pdf/9780470390733.excerpt.pdf', 'Detailed PDF schematics for 3-point lighting setups, diffusion modifiers, gel color temperature (CTO/CTB), and anamorphic squeeze ratios.', 3, 25, 1),
    (8, 'Camera Angles, Lens Choice, and Scene Blocking', 'text', NULL, 'Lesson: Cinematography & Director Camera Placement

Cinematography communicates emotional tone through lens choice, perspective, and camera movement.

1. Lens Focal Lengths:
- Wide (18mm-24mm): Exaggerates distance and environmental context.
- Normal (35mm-50mm): Simulates human eye perspective.
- Telephoto (85mm-135mm): Compresses background and creates shallow depth of field.

2. Camera Angles & Emotional Subtext:
- Low Angle: Imparts power and dominance to the subject.
- High Angle: Conveys vulnerability or powerlessness.

3. Blocking: Moving actors in relation to the camera to keep shots dynamic without unnecessary cuts.', 4, 35, 0);
END
GO
