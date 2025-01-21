# octet_memory_stream
[![View the Alire Crate](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/octet_memory_stream.json)](https://alire.ada.dev/crates/octet_memory_stream)

`octet_memory_stream` provides a standalone `Ada.Streams.Root_Stream_Type`
wrapper around an `Octet_Array` (array of 8-bit bytes,) primarily for the
purpose of protecting an over-arching stream from misalignment while reading
from, or writing to, e.g., a file format.

If the `Memory_Stream` detects an out-of-bounds error as the result of a read
or write operation, an `Out_Of_Bounds_Error` exception will be raised.

**NOTE:** This crate does not currently support writing from a `Memory_Stream`,
however this is a priority and will be done so in update 1.1.0.

Example Use
-----------
All pertinent types and subprograms are available within the package 
`Octet_Memory_Stream`. Wrapping an `Octet_Array` is done through the
`To_Stream` function.
```ada
pragma Ada_2022;

with Ada.Text_IO;
with Ada.Streams.Stream_IO;
use  Ada.Streams.Stream_IO;
with Octet_Memory_Stream;

procedure TestDemo is
   F                : File_Type;
   Protected_Stream : Stream_Access;
   Memory_Stream    : Octet_Memory_Stream.Stream_Access;
begin
   Open (F, In_File, "example");
   Protected_Stream := Stream (F);
   declare
      Data : Octet_Memory_Stream.Octet_Array (1 .. 50);
   begin
      Octet_Memory_Stream.Octet_Array'Read (Protected_Stream, Data);
      Memory_Stream := Octet_Memory_Stream.To_Stream (Data);
   end;
   declare
      OK_Data  : Octet_Memory_Stream.Octet_Array (1 .. 25);
      OOB_Data : Octet_Memory_Stream.Octet_Array (1 .. 26);
   begin
      Octet_Memory_Stream.Octet_Array'Read (Memory_Stream, OK_Data);
      Ada.Text_IO.Put_Line (OK_Data'Image);

      Octet_Memory_Stream.Octet_Array'Read (Memory_Stream, OOB_Data);
      --  exception raised above
      Ada.Text_IO.Put_Line (OOB_Data'Image);
   end;
   Close (F);
end TestDemo;
```
