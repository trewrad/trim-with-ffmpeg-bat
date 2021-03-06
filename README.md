# trim-with-ffmpeg-bat
A batch file to invoke the required commands to trim and re-encode input files.
All processing is done on the GPU with NVENC
Output files are converted to h264

### Usage:
1) Place the bat file in the folder containing input videos
2) Drag & Drop the input video file on the .bat
3) Follow the prompts to enter the 'In-time', 'Out-time', whether to interpolate frames and generate slow motion clips (*),  whether to rescale the output, and specify the bitrate of the output video
4) Final prompt is for the filename which will be appended with '.mp4' as the file extension.
5) All audio tracks are copied over as individual tracks for now, an option to mux all tracks into one or choose which track to include will be added in the future. 
6) For slow motion clipping, due to ffmpeg limitations the script must create a temporary file, then apply the slow motion filter to it. The final output file will be appended with a "-slowmo". The temporary file should be deleted automatically.


### Known Issues:
* Slo-mo uses up a lot of system memory.


###### To-Do 
- [x] Fix Audio Sync issue 
- [x] Solve slow motion generation's obscene resource usage
- [ ] Implement audio track selection/muxing
