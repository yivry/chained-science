<?php

function msg(string $message): void
{
    echo $message, PHP_EOL;
}

function error(string $message): never
{
    msg("Error: {$message}");
    exit(1);
}

if (!extension_loaded('zip')) {
    error("Cannot create a zip file without the zip extension.");
}

$rootPath = __DIR__ . '/mod';
$infoJson = @file_get_contents("{$rootPath}/info.json");

if ($infoJson === false) {
    error("Couldn't get mod info.");
}

try {
    $modInfo = json_decode($infoJson, flags: JSON_OBJECT_AS_ARRAY | JSON_THROW_ON_ERROR);
} catch (Throwable $t) {
    error("Couldn't decode mod info: {$t->getMessage()}");
}

if (!is_array($modInfo)) {
    error("Invalid mod info format.");
}

$modName = $modInfo['name'] ?? null;

if (!is_string($modName)) {
    error("Invalid mod info: missing or invalid name.");
}

msg("Found mod: {$modName}");

$modVersion = $modInfo['version'] ?? null;

if (!is_string($modVersion)) {
    error("Invalid mod info: missing or invalid version.");
}

msg("Version: {$modVersion}");

// Factorio standard: a mod is a zipfile called name_version.zip
$archiveName = __DIR__ . "/build/{$modName}_{$modVersion}.zip";
$archive = new ZipArchive();
$opened = $archive->open($archiveName, ZipArchive::CREATE | ZipArchive::OVERWRITE);

if ($opened !== true) {
    // It can now either be false or an error code.
    if ($opened === false) {
        $opened = 'false';
    }

    error("Couldn't open Zip Archive: {$opened}");
}

msg("Adding mod files:");

$dirIterator = new RecursiveDirectoryIterator(
    $rootPath,
    FilesystemIterator::KEY_AS_PATHNAME
    | FilesystemIterator::CURRENT_AS_FILEINFO
    | FilesystemIterator::SKIP_DOTS,
);

// Skip dots above and leaves only below makes sure we only get actual files
$files = new RecursiveIteratorIterator($dirIterator, RecursiveIteratorIterator::LEAVES_ONLY);

/** @var SplFileInfo $file */
foreach ($files as $file) {
    $filePath = $file->getRealPath();
    $relativePath = substr($filePath, strlen($rootPath) + 1);

    // Factorio standard: all files are within the folder <mod name>
    $zipRelativePath = $modName . '/' . $relativePath;

    msg("- {$relativePath}");
    $added = $archive->addFile($filePath, $zipRelativePath);

    if (!$added) {
        error("Failed to add file.");
    }
}

msg("Adding License and Readme");

foreach (["LICENSE", "README"] as $type) {
    $file = "/{$type}.md";
    $added = $archive->addFile(__DIR__ . $file, $modName . $file);

    if (!$added) {
        error("Failed to add {$type}.");
    }
}

$closed = $archive->close();

if (!$closed) {
    error("Failed to save Zip Archive.");
}

msg("Created mod package:");
msg($archiveName);
