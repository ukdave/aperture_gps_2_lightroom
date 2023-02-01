# Aperture GPS 2 Lightroom

Ruby app to copy GPS data from an Aperture library to Lightroom.

This assumes you have migrated your Aperture library to Lightroom using the "Import from from Aperture library"
plugin in Lightroom. For more info see: https://helpx.adobe.com/uk/lightroom-classic/help/migrate-photos-aperture.html

After doing this I found that all my photos and metadata had been copied over except for GPS data that had
been manually assigned in Aperture.

## Usage

Currently the app only support copying GPS data over in an individual project basis.

```
./bin/aperture_gps_2_lightroom <project_name>
```

Example:

```
./bin/aperture_gps_2_lightroom "Amathus Ruins"
Found 55 versions with GPS in Amathus Ruins
Updating location for 2010/08/2010-08-13/IMG_1437.JPG  to 0.34711878889375726e2, 0.33143230676651e2
Updating location for 2010/08/2010-08-13/IMG_1438.JPG  to 0.34711878889375726e2, 0.33143230676651e2
Updating location for 2010/08/2010-08-13/IMG_1439.JPG  to 0.347102120093513e2, 0.3314221143722534e2
Updating location for 2010/08/2010-08-13/IMG_1440.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1441.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1443.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1443.JPG VERSION-2 to 0.34711296808105e2, 0.3314144432544708e2
WARNING: Cowardly refusing to overwrite GPS location for 2010/08/2010-08-13/IMG_1443.JPG
WARNING: Cowardly refusing to overwrite GPS location for 2010/08/2010-08-13/IMG_1443.JPG VERSION-2
Updating location for 2010/08/2010-08-13/IMG_1444.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1445.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1446.JPG  to 0.34711296808105e2, 0.3314144432544708e2
Updating location for 2010/08/2010-08-13/IMG_1447.JPG  to 0.347122669412804e2, 0.3314048409461975e2
Updating location for 2010/08/2010-08-13/IMG_1448.JPG  to 0.347122669412804e2, 0.3314048409461975e2
...
```

## Dev Notes

Both Aperture and Lightroom use [SQLite](https://www.sqlite.org/index.html) for the databases.

Process overview:

1. Get Aperture versions in given project that have a GPS location
2. Load/Generate static file with SHA1 hashes of all lightroom images
3. Iterate over Aperture versions
   1. Find lightroom images with matching file hash
   2. Update lightroom image GPS

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
