with Ada.Tags;
with Ada.Unchecked_Deallocation;
package body Octet_Memory_Stream is

   function To_Stream (Of_Array : Octet_Array) return Stream_Access is
   begin
      return
        new Memory_Stream'
          (Root_Stream_Type
           with
             Wrapped_Array => new Octet_Array'(Of_Array),
             Position      => Of_Array'First);
   end To_Stream;

   function To_Octet_Array (From : String) return Octet_Array is
      New_Array : Octet_Array (Stream_Element_Offset (From'First) ..
                               Stream_Element_Offset (From'Last));
   begin
      for From_Index in From'Range loop
         New_Array (Stream_Element_Offset (From_Index)) :=
            Octet (Character'Pos (From (From_Index)));
      end loop;
      return New_Array;
   end To_Octet_Array;

   function Index (Stream : Stream_Access) return Stream_Element_Offset is
      use type Ada.Tags.Tag;
   begin
      if Stream.all'Tag = Memory_Stream'Tag then
         return Memory_Stream (Stream.all).Position;
      end if;
      raise Program_Error with "Index on a non memory stream";
   end Index;

   procedure Free (Stream : out Stream_Access) is
      procedure Free_Memory_Stream is
         new Ada.Unchecked_Deallocation (Memory_Stream, Memory_Stream_Access);
      procedure Free_Octet_Array is
         new Ada.Unchecked_Deallocation (Octet_Array, Octet_Array_Access);
      use type Ada.Tags.Tag;
   begin
      if Stream /= null and then Stream.all'Tag = Memory_Stream'Tag then
         Free_Octet_Array (Memory_Stream (Stream.all).Wrapped_Array);
         Free_Memory_Stream (Memory_Stream_Access (Stream));
         return;
      end if;
      raise Program_Error with "Free on a non memory stream";
   end Free;

   overriding
   procedure Read
     (Stream : in out Memory_Stream;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset)
   is
   begin
      for Item_Index in Item'First .. Item'Last loop
         Item (Item_Index) :=
           Stream_Element (Stream.Wrapped_Array.all (Stream.Position));
         Stream.Position := @ + 1;
      end loop;
      Last := Item'Last;
   exception
      when Constraint_Error =>
         raise Out_Of_Bounds_Error
            with "Reading beyond stream limit; octet array size is" &
            Stream.Wrapped_Array.all'Length'Image & ", current position:" &
            Stream.Position'Image & ", item buffer size:" & Item'Length'Image;
   end Read;

   --  Untested! Please report bugs!
   overriding
   procedure Write (Stream : in out Memory_Stream; Item : Stream_Element_Array)
   is
   begin
      for Item_Index in Item'First .. Item'Last loop
         Stream.Wrapped_Array.all (Stream.Position) :=
            Octet (Item (Item_Index));
         Stream.Position := @ + 1;
      end loop;
   exception
      when Constraint_Error =>
         raise Out_Of_Bounds_Error
            with "Writing beyond stream limit; octet array size is" &
            Stream.Wrapped_Array.all'Length'Image & ", current position:" &
            Stream.Position'Image & ", item buffer size:" & Item'Length'Image;
   end Write;

end Octet_Memory_Stream;
