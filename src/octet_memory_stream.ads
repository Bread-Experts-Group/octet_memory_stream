with Ada.Streams; use Ada.Streams;

package Octet_Memory_Stream is

   Out_Of_Bounds_Error : exception;

   type Octet is mod 2 ** 8 with Size => 8;

   type Octet_Array is array (Stream_Element_Offset range <>) of Octet;

   type Octet_Array_Access is access Octet_Array;

   type Memory_Stream is limited private;

   type Stream_Access is access all Ada.Streams.Root_Stream_Type'Class;

   type Memory_Stream_Access is access all Memory_Stream;

   function To_Stream (Of_Array : Octet_Array) return Stream_Access;

   function To_Octet_Array (From : String) return Octet_Array;

   function Index (Stream : Stream_Access) return Stream_Element_Offset;

   procedure Free (Stream : out Stream_Access);

private

   type Memory_Stream is new Root_Stream_Type with record
      Wrapped_Array : Octet_Array_Access;
      Position      : Stream_Element_Offset;
   end record;

   overriding
   procedure Read
     (Stream : in out Memory_Stream;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset);

   overriding
   procedure Write
     (Stream : in out Memory_Stream; Item : Stream_Element_Array);

end Octet_Memory_Stream;
