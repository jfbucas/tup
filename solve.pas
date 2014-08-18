program TUP;

type
	t_board 	= array[ 0..15 ] of array[ 0..3 ] of byte;
	t_inserted	= string;
	t_position_depth = array[ 0..15 ] of longint;
	t_pieces	=  array[ 0.. 15 ] of array[ 0 .. 4*8 -1] of byte;

const	symb : string = '+0ab*OAB';

var	pieces, pieces_inverted : t_pieces;
	position_xy, position_up, position_ri, position_do, position_le : t_position_depth;

function invert( s : byte ): byte;
begin
	invert := ((1-( s shr 2 )) shl 2) or (s and 3);
end;

procedure piece_mirror( s_up:byte; s_ri:byte; s_do:byte; s_le:byte;
			var n_up:byte; var n_ri:byte; var n_do:byte; var n_le:byte );
begin
		n_up := s_up;
		n_ri := s_le;
		n_do := s_do;
		n_le := s_ri;
end;

procedure piece_turn_clockwise( s_up:byte; s_ri:byte; s_do:byte; s_le:byte;
			var n_up:byte; var n_ri:byte; var n_do:byte; var n_le:byte );
begin
		n_up := s_le;
		n_ri := s_up;
		n_do := s_ri;
		n_le := s_do;
end;

procedure print_board( board : t_board );
var	i, j : longint;
	l1, l2, l3, up, ri, od, le : string;
begin
	writeln('-----------');

	for j := 0 to 3 do
	begin
		l1 := '';
		l2 := '';
		l3 := '';
		for i := 0 to 3 do
		begin
			up := ' '; ri := ' '; od := ' '; le := ' ';
			if board[ i+j*4 ][ 0 ] <> 255 then
				up := symb[ invert(board[ i+j*4 ][ 0 ])+1 ];
			if board[ i+j*4 ][ 1 ] <> 255 then
				ri := symb[ invert(board[ i+j*4 ][ 1 ])+1 ];
			if board[ i+j*4 ][ 2 ] <> 255 then
				od := symb[ invert(board[ i+j*4 ][ 2 ])+1 ];
			if board[ i+j*4 ][ 3 ] <> 255 then
				le := symb[ invert(board[ i+j*4 ][ 3 ])+1 ];

			l1 := l1 + '  ' + up+up + '  ';
			l2 := l2 + le+le + '  ' + ri+ri;
			l3 := l3 + '  ' + od+od + '  ';
		end;
		writeln(l1);
		writeln(l2);
		writeln(l3);
	end;
end;


function do_recurs(
		depth		: longint;
		board		: t_board;
		inserted	: t_inserted
	): longint;
var	i, p, rot, xy, xy_up, xy_ri, xy_do, xy_le, result : longint;
	new_inserted : string;
	match : boolean;
begin
	result := 0;

	if length(inserted) = 0 then
	begin
		writeln('All on board');
		print_board( board );
	end
	else
	begin

		xy    := position_xy[ depth ];
		xy_up := position_up[ depth ];
		xy_ri := position_ri[ depth ];
		xy_do := position_do[ depth ];
		xy_le := position_le[ depth ];
			

		for i := 1 to length(inserted) do
		begin
			p := ord(inserted[i]) - ord('a');
			
			for rot := 0 to 7 do
			begin

				// match sides
				match := ( 
						(xy_up = 255) or
						(board[ xy_up ][ 0 ] = 255) or
						((board[ xy_up ][ 0 ] <> 255) and
						 (board[ xy_up ][ 2 ] = pieces[ p ][ rot*4 + 0 ]))
					)
					and
					( 
						(xy_ri = 255) or
						(board[ xy_ri ][ 0 ] = 255) or
						((board[ xy_ri ][ 0 ] <> 255) and
						 (board[ xy_ri ][ 3 ] = pieces[ p ][ rot*4 + 1 ]))
					) and
					( 
						(xy_do = 255) or
						(board[ xy_do ][ 0 ] = 255) or
						((board[ xy_do ][ 0 ] <> 255) and
						 (board[ xy_do ][ 0 ] = pieces[ p ][ rot*4 + 2 ]))
					) and
					( 
						(xy_le = 255) or
						(board[ xy_le ][ 0 ] = 255) or
						((board[ xy_le ][ 0 ] <> 255) and
						 (board[ xy_le ][ 1 ] = pieces[ p ][ rot*4 + 3 ]))
					);


				//
				if match then
				begin
					new_inserted := '';
					if i > 0 then
						new_inserted := copy( inserted, 1, i-1 );

					if i < length( inserted )  then
						new_inserted := new_inserted + copy( inserted, i+1, length(inserted) );
						
					board[ xy ][ 0 ] := pieces_inverted[ p ][ 4*rot + 0 ];
					board[ xy ][ 1 ] := pieces_inverted[ p ][ 4*rot + 1 ];
					board[ xy ][ 2 ] := pieces_inverted[ p ][ 4*rot + 2 ];
					board[ xy ][ 3 ] := pieces_inverted[ p ][ 4*rot + 3 ];

					result := result + do_recurs( depth+1, board, new_inserted );

					board[ xy ][ 0 ] := 255;
					board[ xy ][ 1 ] := 255;
					board[ xy ][ 2 ] := 255;
					board[ xy ][ 3 ] := 255;
				end;
			end;
		end;
	end;
	do_recurs := result;
end;




var	f		: text;
	board		: t_board;
	inserted	: t_inserted;
	p, i, j, ij, rot, rat, depth	: longint;
	l		: string;
begin

	assign(f, 'Pieces.txt' );
	reset(f);
	p := 0;
	while not eof(f) do
	begin
		readln(f, l);
		for i := 1 to length( l ) do
			pieces[ p ][ i-1 ] := pos(l[i], symb)-1;

		p := p + 1;
	end;
	close(f);


	for p := 0 to 15 do
	begin

		// Mirror the first rotation
		piece_mirror(
			pieces[ p ][ 4*0 + 0 ],
			pieces[ p ][ 4*0 + 1 ],
			pieces[ p ][ 4*0 + 2 ],
			pieces[ p ][ 4*0 + 3 ],

			pieces[ p ][ 4*4 + 0 ],
			pieces[ p ][ 4*4 + 1 ],
			pieces[ p ][ 4*4 + 2 ],
			pieces[ p ][ 4*4 + 3 ]
			);


		for rot := 1 to 7 do
		if rot <> 4 then
		begin
			rat := rot - 1;
			piece_turn_clockwise(
				pieces[ p ][ 4*rat + 0 ],
				pieces[ p ][ 4*rat + 1 ],
				pieces[ p ][ 4*rat + 2 ],
				pieces[ p ][ 4*rat + 3 ],

				pieces[ p ][ 4*rot + 0 ],
				pieces[ p ][ 4*rot + 1 ],
				pieces[ p ][ 4*rot + 2 ],
				pieces[ p ][ 4*rot + 3 ]
				);
		end;
	end;

	for p := 0 to 15 do
		for rot := 0 to 7 do
			for i := 0 to 3 do
				pieces_inverted[ p ][ rot*4 + i ] := invert(pieces[ p ][ rot*4 + i ]);


	for depth := 0 to 15 do
	begin
		position_xy[ depth ] := depth;
		position_up[ depth ] := 255;
		position_ri[ depth ] := 255;
		position_do[ depth ] := 255;
		position_le[ depth ] := 255;

		if depth > 3 then
			position_up[ depth ] := depth - 4;
		if depth < 12 then
			position_do[ depth ] := depth + 4;

		if (depth mod 4) > 0 then
			position_le[ depth ] := depth - 1;
		if (depth mod 4) < 3 then
			position_ri[ depth ] := depth + 1;
	end;



	inserted := '';
	for i := 0 to 15 do
	begin
		for j := 0 to 3 do
			board[ i ][ j ] := 255;

		inserted := inserted + chr( ord('a') + i );
	end;

	writeln(' Solutions : ', do_recurs( 0, board, inserted ));
end.
