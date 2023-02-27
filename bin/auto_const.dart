import 'dart:io';

class FileToChange {
  FileToChange({
    required this.path,
    required this.line,
    required this.column,
  });

  factory FileToChange.fromLineWithData(String lineWithData) {
    final splited = lineWithData.split(':');
    return FileToChange(
      path: splited[0],
      line: int.parse(splited[1]),
      column: int.parse(splited[2]),
    );
  }

  final int column;
  final int line;
  final String path;

  @override
  String toString() {
    return '$path:$line:$column';
  }
}

Future<void> main(List<String> arguments) async {
  await analyzeAndAddConsts();
  await reanalyzeAndRemoveUnnecessaryConsts();
}

Future<void> reanalyzeAndRemoveUnnecessaryConsts() async {
  stdout.writeln('### Started analyze to remove unnecessary const ###');
  final resultAnalyze = Process.runSync('dart', ['analyze']);
  final stdOutAnalyze = resultAnalyze.stdout;
  final constRegex = RegExp('.*unnecessary_const.*\n', multiLine: true);
  final allMatchs = constRegex.allMatches(stdOutAnalyze);
  final lineRegex = RegExp("info - (.*) - Unnecessary 'const'");
  final filesToChange = <FileToChange>[];
  for (var match in allMatchs) {
    final matchLine = match.group(0)!.trim();
    final lineMatch = lineRegex.firstMatch(matchLine);
    final lineWithData = lineMatch!.group(1);
    filesToChange.add(FileToChange.fromLineWithData(lineWithData!));
  }

  stdout.writeln('Consts to remove: ${filesToChange.length}');

  for (var file in filesToChange) {
    var f = File(file.path);
    final lines = await f.readAsLines();
    var lineToChange = lines.elementAt(file.line - 1);
    lineToChange = lineToChange.replaceAll('const ', '');
    lines[file.line - 1] = lineToChange;
    final newTextData = lines.join('\n');
    await f.writeAsString(newTextData);
    stdout.writeln('Removed const on: $file');
  }
  stdout.writeln('Removed ${filesToChange.length} unnecessaries const');
}

Future<void> analyzeAndAddConsts() async {
  stdout.writeln('### Started analyze ###');
  final resultAnalyze = Process.runSync('dart', ['analyze']);
  final stdOutAnalyze = resultAnalyze.stdout;
  final constRegex = RegExp('.*prefer_const_constructors.*\n', multiLine: true);
  final allMatchs = constRegex.allMatches(stdOutAnalyze);
  final lineRegex = RegExp("info - (.*) - Use 'const'");
  final filesToChange = <FileToChange>[];
  for (var match in allMatchs) {
    final matchLine = match.group(0)!.trim();
    final lineMatch = lineRegex.firstMatch(matchLine);
    final lineWithData = lineMatch!.group(1);
    var fileToChange = FileToChange.fromLineWithData(lineWithData!);
    final hasChangeToThisLine = filesToChange.indexWhere(
          (element) => element.line == fileToChange.line,
        ) !=
        -1;

    if (!hasChangeToThisLine) {
      filesToChange.add(fileToChange);
    }
  }
  stdout.writeln('Const to add: ${filesToChange.length}');

  for (var file in filesToChange) {
    var f = File(file.path);
    final lines = await f.readAsLines();
    var lineToChange = lines.elementAt(file.line - 1);
    lineToChange =
        lineToChange.replaceRange(file.column - 1, file.column - 1, 'const ');
    lines[file.line - 1] = lineToChange;
    final newTextData = lines.join('\n');
    await f.writeAsString(newTextData);
    stdout.writeln('Add const on: $file');
  }

  stdout.writeln('Added ${filesToChange.length} consts');
}
