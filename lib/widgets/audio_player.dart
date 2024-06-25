import 'dart:async';

import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/wake_lock.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class AudioPlayer extends StatefulWidget {
  final String path;
  final double? width;
  final Color fixedWaveColor;
  final Color liveWaveColor;
  final Color iconColor;
  final Color btnBgColor;
  final double iconSize;

  const AudioPlayer({
    super.key,
    required this.path,
    this.width,
    this.fixedWaveColor = Colors.white54,
    this.liveWaveColor = Colors.white,
    this.iconColor = Colors.white,
    this.btnBgColor = const Color(0xff0045F5),
    this.iconSize = 28.0,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  late PlayerController _playerCtl;
  late PlayerWaveStyle _playerWaveStyle;
  late StreamSubscription<PlayerState> playerStateSubscription;
  bool _isPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initPlayer();
  }

  void _initPlayer({String? path}) async {
    String p = path ?? widget.path;
    _playerCtl = PlayerController();
    _playerWaveStyle = PlayerWaveStyle(
      fixedWaveColor: widget.fixedWaveColor,
      liveWaveColor: widget.liveWaveColor,
      spacing: 6,
    );
    _playerCtl.preparePlayer(
      path: p,
      shouldExtractWaveform: false,
    );
    if (mounted) {
      _playerCtl
          .extractWaveformData(
            path: p,
            noOfSamples: _playerWaveStyle.getSamplesForWidth(
              ResponsiveUtil.ratio(context, widget.width ?? 140.0),
            ),
          )
          .then((waveformData) => debugPrint(waveformData.toString()));
    }
    _playerCtl.onCompletion.listen((_) async{
      setState(()  {
        _isPlaying = false;
      });
      await WakelockChannel.toggle(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            if (_playerCtl.playerState.isInitialised) {
              await _playerCtl.startPlayer(finishMode: FinishMode.pause);
              await WakelockChannel.toggle(true);
            } else if (_playerCtl.playerState.isPlaying) {
              await _playerCtl.pausePlayer();
              await WakelockChannel.toggle(false);
            } else if (_playerCtl.playerState.isStopped) {
              await _playerCtl.startPlayer(finishMode: FinishMode.pause);
              await WakelockChannel.toggle(true);
            } else if (_playerCtl.playerState.isPaused) {
              await _playerCtl.startPlayer(finishMode: FinishMode.pause);
              await WakelockChannel.toggle(true);
            }
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          child: !_isPlaying
              ? _anyButton(Icons.play_arrow_rounded)
              : _anyButton(Icons.pause_rounded),
        ),
        SizedBox(width: ResponsiveUtil.ratio(context, 4.0)),
        AudioFileWaveforms(
          size: Size(
            ResponsiveUtil.ratio(context, widget.width ?? 140.0),
            ResponsiveUtil.ratio(context, 60.0),
          ),
          playerController: _playerCtl,
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: _playerWaveStyle,
        ),
      ],
    );
  }

  Widget _anyButton(IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.ratio(context, 12.0),
        vertical: ResponsiveUtil.ratio(context, 12.0),
      ),
      decoration: BoxDecoration(
        color: widget.btnBgColor,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Icon(
        icon,
        size: widget.iconSize,
        color: widget.iconColor,
      ),
    );
  }

  @override
  void dispose() {
    _playerCtl.dispose();
    super.dispose();
  }
}
