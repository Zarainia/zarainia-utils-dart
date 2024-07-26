import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:unified_sounds/unified_sounds.dart';
import 'package:zarainia_utils/src/exports.dart';

class AudioPlaybackButton extends StatefulWidget {
  final Uint8List audio;
  final Color? icon_colour;
  final Color? playing_icon_colour;

  const AudioPlaybackButton({required this.audio, this.icon_colour, this.playing_icon_colour});

  @override
  _AudioPlaybackButtonState createState() => _AudioPlaybackButtonState();
}

class _AudioPlaybackButtonState extends State<AudioPlaybackButton> {
  AudioPlayer player = AudioPlayer();
  bool playing = false;

  @override
  void initState() {
    player.playback_callback = (status) {
      setState(() {
        playing = status.is_playing;
      });
    };
  }

  Future play_audio() async {
    player.reset();
    await player.load_bytes(widget.audio);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return PaddingLessIconButton(
      icon: const Icon(Icons.volume_up),
      icon_size: 20,
      colour: playing ? (widget.playing_icon_colour ?? theme_colours.ACCENT_COLOUR) : widget.icon_colour ?? theme_colours.PRIMARY_ICON_COLOUR,
      on_click: play_audio,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      tooltip: "Play audio",
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}

class _AudioControlIcon extends StatelessWidget {
  final IconData icon;
  final double icon_size_adjustment;
  final String? tooltip;
  final VoidCallback inactive_action;
  final VoidCallback? active_action;
  final bool active;
  final bool enabled;
  final bool smaller;

  _AudioControlIcon({
    required this.icon,
    this.icon_size_adjustment = 1,
    required this.inactive_action,
    this.active_action,
    this.tooltip,
    this.active = false,
    this.enabled = true,
    this.smaller = false,
  });

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return IconButton(
      icon: Icon(icon),
      iconSize: 27 * icon_size_adjustment * (smaller ? 0.8 : 1),
      color: active ? theme_colours.ACCENT_COLOUR : theme_colours.ICON_COLOUR,
      onPressed: enabled ? (active ? active_action ?? inactive_action : inactive_action) : null,
      tooltip: tooltip,
    );
  }
}

class SimpleAudioRecorder extends StatefulWidget {
  final Uint8List? curr_audio;
  final Function(Uint8List?) on_change;
  final bool smaller;
  final bool show_header;

  const SimpleAudioRecorder({this.curr_audio, required this.on_change, this.smaller = false, this.show_header = true});

  @override
  _SimpleAudioRecorderState createState() => _SimpleAudioRecorderState();
}

class _SimpleAudioRecorderState extends State<SimpleAudioRecorder> {
  AudioPlayer player = AudioPlayer();
  AudioRecorder recorder = AudioRecorder();

  bool playing = false;
  bool recording = false;

  @override
  void initState() {
    super.initState();
    player.playback_callback = (status) {
      setState(() {
        playing = status.is_playing;
      });
    };
  }

  Future play_audio() async {
    player.reset();
    await player.load_bytes(widget.curr_audio!);
    player.play();
  }

  Future stop_audio() async {
    player.stop();
  }

  Future start_recording() async {
    if (await recorder.hasPermission()) {
      await recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '',
      );
      setState(() {
        recording = true;
      });
    }
  }

  Future stop_recording() async {
    String? path = await recorder.stop();
    setState(() {
      recording = false;
    });
    await Future.delayed(Duration(milliseconds: 200));
    if (path != null) {
      File file = new File(path);
      Uint8List bytes = await file.readAsBytes();
      await file.delete();
      if (bytes.isNotEmpty) widget.on_change(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    ZarainiaTheme theme_colours = get_zarainia_theme(context);

    return Column(
      children: [
        Row(
          children: [
            if (widget.show_header)
              Padding(
                child: IconAndText(
                  icon: Icons.volume_up,
                  text: "Audio",
                  style: widget.smaller ? theme_colours.SMALLER_HEADER_STYLE : theme_colours.SMALL_HEADER_STYLE,
                ),
                padding: const EdgeInsets.only(right: 20),
              ),
            _AudioControlIcon(
              icon: Icons.play_arrow,
              icon_size_adjustment: 1.3,
              inactive_action: play_audio,
              active_action: stop_audio,
              enabled: !recording && widget.curr_audio != null && widget.curr_audio!.isNotEmpty,
              active: playing,
              tooltip: "Play",
              smaller: widget.smaller,
            ),
            _AudioControlIcon(
              icon: Icons.fiber_manual_record,
              inactive_action: start_recording,
              active_action: stop_recording,
              active: recording,
              enabled: !playing,
              tooltip: "Record",
              smaller: widget.smaller,
            ),
            if (widget.curr_audio != null)
              _AudioControlIcon(
                icon: Icons.delete,
                inactive_action: () => widget.on_change(null),
                enabled: !recording && !playing,
                tooltip: "Delete",
                smaller: widget.smaller,
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
