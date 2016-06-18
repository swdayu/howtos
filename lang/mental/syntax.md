
```c
struct  {
  void* 
};

struct 

concept Readable(T) {
  func get(T) @error, byte
  func read(T, int bytes) [byte]
}

concept Writeable(T) {
  func put(inout T, byte data) int
  func write(inout T, [byte] data) int 
}

import io.conc.Readable Writeable
func encodeB2T(!I in, !O out) { Readable(T), Writeable(O) |
  
}

func decodeB2T(!I in, !O out) { Readable(T), Writeable(O) |

}

func Readable.encode(self, Writeable out) {
  
}

ifs:Readable.toText(ofs:Writeable)

```
