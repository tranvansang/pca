small_n = 100;
c = 3;
n = c * small_n;

#gen data
x1 = rand(3, small_n) * 10;
x2 = rand(3, small_n) * 10 + 23 ;
x3 = rand(3, small_n) * 10 + 27;
x = [x1 x2 x3];
red = [1;0;0];
green = [0;1;0];
blue = [0;0;1];
color = [repmat(red, 1, small_n) repmat(green,1, small_n) repmat(blue, 1, small_n)];


function retval = mypca(x, d, m)
	c = x * x';
	[v, lambda] = eig(c);
	lambda = diag(lambda);
	[lambda, index] = sort(lambda, "descend");
	v = v(:, index);
	t = v(:,1:m)';

	for i = 1:m
		t(i,:) = t(i,:) / norm(t(i,:));
	endfor

	retval = t * x;
endfunction


y = mypca(x, 3, 2);

function draw3d(data, color)
	x = data(1,:);
	y = data(2,:);
	z = data(3,:);
	scatter3(x, y, z, [], color');
endfunction


function draw2d(data, color, style)
	x = data(1,:);
	y = data(2,:);
	scatter(x, y, [], color', style);
endfunction

function draw_center(data, color, style, size)
	x = data(1,:);
	y = data(2,:);
	scatter(x, y, size, color, style);
endfunction

function [retval, u] = k_mean(x, c)
	d = rows(x);
	u = rand(d, c);
	n = columns(x);
	eps = 0.1;
	cnt = 0;
	threshold = 10;
	do
		#hold on;
		#draw_center(u, "k", "^", 15);
		cnt = cnt + 1;
		big_u = reshape(u, c * d, 1);
		dist = repmat(x, c, 1) - repmat(big_u, 1, n);
		dist = dist .^ 2;
		t1 = sum(dist(1:d, :));
		t2 = sum(dist(d+1:2*d, :));
		t3 = sum(dist(2*d+1:c*d, :));
		t = [t1; t2; t3];
		[dump, retval] = min(t);
		x1 = [];
		x2 = [];
		x3 = [];
		for i = 1:n
			if retval(i) == 1
				x1 = [x1 x(:, i)];
			else
				if retval(i) == 2
					x2 = [x2 x(:, i)];
				else
					x3 = [x3 x(:, i)];
				endif
			endif
		endfor
		sum1 = sum(x1, 2);
		sum2 = sum(x2, 2);
		sum3 = sum(x3, 2);
		#backup
		last_u = u;
		if columns(x1) > 0
			u(:,1) = sum1 / columns(x1);
		endif
		if columns(x2) > 0
			u(:,2) = sum2 / columns(x2);
		endif
		if columns(x3) > 0
			u(:,3) = sum3 / columns(x3);
		endif
		ok = norm(u - last_u) < eps || cnt > threshold;
	until (ok);
endfunction

function draw_data(data, style1, style2, style3, color1, color2, color3, type)
	data1 = [];
	data2 = [];
	data3 = [];
	n = columns(data);
	for i = 1:n
		if type(i) == 1
			color(:,i) = color1;
			data1 = [data1 data(:, i)];
		else
			if type(i) == 2
				color(:,i) = color2;
				data2 = [data2 data(:, i)];
			else
				color(:,i) = color3;
				data3 = [data3 data(:, i)];
			endif
		endif
	endfor
	draw2d(data1, color1, style1);
	draw2d(data2, color2, style2);
	draw2d(data3, color3, style3);
endfunction

#draw3d(x, color);
[type, u] = k_mean(y, c);
hold on;
draw_data(y, "*", "x", "o", red, green, blue, type);
hold on;
draw_center(u, "k", "+", 15);
