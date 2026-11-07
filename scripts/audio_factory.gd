extends RefCounted
## Original project audio generated from compact source; no sampled recordings.

static func create(kind: String) -> AudioStreamWAV:
	var rate := 11025
	var seconds := 32.0 if kind == "music" else (16.0 if kind == "ocean" else 0.18)
	var count := int(seconds*rate)
	var bytes := PackedByteArray()
	bytes.resize(count*2)
	var random := RandomNumberGenerator.new()
	random.seed = 421
	var brown := 0.0
	var notes := [60,67,72,64,69,67,64,62,60,64,67,72,69,64,62,67]
	for i in range(count):
		var t := float(i)/rate
		var sample := 0.0
		if kind == "ocean":
			brown = brown*0.97+random.randf_range(-1,1)*0.03
			sample = brown*(0.35+0.22*sin(t*PI/4))+0.014*random.randf_range(-1,1)
		elif kind == "music":
			for k in range(maxi(0,int(t/2)-2),int(t/2)+1):
				var x := t-k*2
				var frequency := 440.0*pow(2.0,float(notes[k%notes.size()]-69)/12)
				sample += 0.23*exp(-x*2.2)*(1-exp(-x*55))*(sin(TAU*frequency*x)+0.25*sin(TAU*frequency*3*x))
			sample += 0.022*sin(TAU*130.8128*t)*pow(sin(PI*t/32),2)
		else:
			sample = 0.25*exp(-t*26)*sin(TAU*(620*t+260*t*t))
		bytes.encode_s16(i*2,int(clampf(sample,-1,1)*32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = bytes
	if kind != "effect":
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = count
	return stream
