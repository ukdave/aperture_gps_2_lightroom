# Aperture GPS 2 Lightroom

## Dev Notes

Both Aperture and Lightroom use [SQLite](https://www.sqlite.org/index.html) for the databases.

### Aperture Database

Aperture database location: `Aperture Library.aplibrary/Database/apdb/Library.apdb`

Sample queries:

```sql
-- Show GPS for specific version
SELECT exifLatitude, exifLongitude
FROM RKVersion
WHERE uuid = '5Cclfkh7QpaQP6glm+Bp3w';

-- Show GPS for all versions in a given project
SELECT masterUuid, fileName, versionNumber, exifLatitude, exifLongitude
FROM RKVersion
WHERE projectUuid = '7kFRTjp%TGGDRD8GOKl5og'
AND showInLibrary = 1
AND exifLatitude IS NOT NULL
AND exifLongitude IS NOT NULL;

-- List projects
SELECT uuid, Name FROM RKFolder WHERE folderType = 2;
```

### Lightroom Database

Lightroom database location: `Lightroom/Lightroom.lrcat`

Details of database schema: https://github.com/camerahacks/lightroom-database

Sample queries

```sql
-- Find image with full path
SELECT file.*, (root_folder.name || '/' || folder.pathFromRoot || file.idx_filename) AS full_filename
FROM agLibraryFile file
JOIN agLibraryFolder folder ON folder.id_local = file.folder
JOIN agLibraryRootFolder root_folder ON root_folder.id_local = folder.rootFolder
WHERE full_filename = '2007/06/2007-06-13/IMG_0001_770.jpg';

-- Find GPS for a specific image (separate queries)
SELECT id_local FROM agLibraryFile WHERE idx_filename = 'IMG_0115_1746.jpg';
SELECT id_local FROM Adobe_images WHERE rootFile = 765710; -- id_local from agLibraryFile
SELECT hasGPS, gpsLatitude, gpsLongitude FROM AgharvestedExifMetadata WHERE image = 765708; -- id_local Adobe_images

-- Find GPS for a specific image (single query)
SELECT em.hasGPS, em.gpsLatitude, em.gpsLongitude
FROM agLibraryFile lf
JOIN Adobe_images ai ON ai.rootFile = lf.id_local
JOIN AgharvestedExifMetadata em ON em.image = ai.id_local
WHERE lf.idx_filename = 'IMG_0115_1746.jpg';

-- Set GPS for a specific image
UPDATE AgharvestedExifMetadata
SET hasGPS = 1, gpsLatitude = 42.35847222166667, gpsLongitude = -71.091325, gpsSequence = 1
WHERE image = 765708;
