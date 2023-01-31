function my_tests()
	% calcul des descripteurs de Fourier de la base de données
	img_db_path = './db/';
	img_db_list = glob([img_db_path, '*.gif']);
	img_db = cell(1);
	label_db = cell(1);
	fd_db = cell(1);
	for im = 1:numel(img_db_list);
		img_db{im} = logical(imread(img_db_list{im}));
		label_db{im} = get_label(img_db_list{im});
		disp(label_db{im}); 
		[fd_db{im},~,~,~] = compute_fd(img_db{im});
	end

	% importation des images de requête dans une liste
	img_path = './dbq/';
	img_list = glob([img_path, '*.gif']);
	t=tic()

	% pour chaque image de la liste...
	for im = 1:numel(img_list)

		% calcul du descripteur de Fourier de l'image
		img = logical(imread(img_list{im}));
		[fd,r,m,poly] = compute_fd(img);

		% calcul et tri des scores de distance aux descripteurs de la base
		for i = 1:length(fd_db)
			scores(i) = norm(fd-fd_db{i});
		end
		[scores, I] = sort(scores);

		% affichage des résultats    
		close all;
		figure(1);
		top = 5; % taille du top-rank affiché
		subplot(2,top,1);
		imshow(img); hold on;
		plot(m(1),m(2),'+b'); % affichage du barycentre
		plot(poly(:,1),poly(:,2),'v-g','MarkerSize',1,'LineWidth',1); % affichage du contour calculé
		subplot(2,top,2:top);
		plot(r); % affichage du profil de forme
		for i = 1:top
			subplot(2,top,top+i);
			imshow(img_db{I(i)}); % affichage des top plus proches images
		end
		drawnow();
		waitforbuttonpress();
	end
end

function [fd,r,m,poly] = compute_fd(img)
	N = 110; % nombre de valeurs d'angle
	M = 63; % nombre des M premiers coefficients du vecteur R(f) / R(0)
	h = size(img,1);
	w = size(img,2);
	%liste des points égaux à 1, equivalent a find(img>0)
	[col, row] = find(img);
	% somme de toutes les colonnes avec des pixels blancs
	% somme de toutes les lignes avec des pixels blancs
	% puis moyenne
	m = mean([row, col]);   % on inverse row et col pour le barycentre pixel blanc
	x = m(1); y = m(2);

	r = zeros(1,N);
	poly = zeros(N,2);
	t = linspace(0,2*pi,N);

	for k = 1:N   %parcours de chacun des N angles
		l=1;
		tmpX = x;
		tmpY = y;

		% tant que l'on ne depasse pas encore les bordures de l'image
		while((tmpX > 1 && tmpY > 1)&&(tmpX < w && tmpY < h))
			% point qui se trouve sur la droite de l'angle
			tmpX = round(x + l * cos(t(1,k)));
			tmpY = round(y + l * sin(t(1,k)));
			l = l+1;
		end

		%bord de l'image
		bordAbs = tmpX;
		bordOrd = tmpY;
		iters = l;
		n=1;

		% operation entre poly et tmp
		while(n<iters)
			%calcul de la distance au barycentre en provenance du bord de l'image
			tmpX=round(bordAbs-n*cos(t(1,k)));
			tmpY=round(bordOrd-n*sin(t(1,k)));
			% on s'arrete si on trouve un pixel blanc et on ajoute le contour dans le polygone
			if (img(tmpY,tmpX) == 1)
				poly(k,1)=tmpX;
				poly(k,2)=tmpY;
				r(1,k)=((tmpX-x).^2+(tmpY-y).^2).^(1/2);
				break;
			end
			n=n+1;

		end
		if(n==iters)
			poly(k,1) = bordAbs;
			poly(k,2) = bordOrd;
			r(1,k) = ((bordAbs - x).^2 + (bordOrd - y).^2).^(1/2);


		end

	end


	fd = zeros(1,N);
	R(1, 1:M) = fft(r(1,1:M));
	tf_r0 = R(1);
	fd(1, 1:M) = abs(R(1,1:M))/abs(tf_r0);


end
