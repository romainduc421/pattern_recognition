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
	h = size(img,1); % hauteur de l'image
	w = size(img,2); % largeur de l'image
	m = barycentre(img);% calcul du barycentre de l'image
	x = m(1); y = m(2); % coordonnées du barycentre

	% initialisation
	r = zeros(1,N);
	poly = zeros(N,2);
	t = linspace(0,2*pi,N);

	for k = 1:N   %parcours de chacun des N angles
		l=1;
		tmpX = x;
		tmpY = y;

		% tant que l'on ne depasse pas encore les bordures de l'image
		while(tmpX > 1 && tmpY > 1 && tmpX < w && tmpY < h)
			% point qui se trouve sur la droite de l'angle
			res = cartesianCoord(x,y,l,t(1,k)); % on va de l'interieur vers l'exterieur
			tmpX = res(1);
			tmpY = res(2);
			l = l+1;
		end

		%bord de l'image
		bordAbs = tmpX;
		bordOrd = tmpY;
		iters = l;


		% on parcourt le contour de l'image
		for n = 1:iters
			%calcul de la distance au barycentre en provenance du bord de l'image
			res = cartesianCoord(bordAbs,bordOrd,-n,t(1,k)); % on va de l'exterieur vers l'interieur
			tmpX = res(1);
			tmpY = res(2);
			% on s'arrete si on trouve un pixel blanc et on ajoute le contour dans le polygone
			if (img(tmpY,tmpX) == 1)
				poly(k,1)=tmpX;
				poly(k,2)=tmpY;
				r(1,k) = distanceEucl(x, y, tmpX, tmpY);% distance euclidienne entre le barycentre et le point du contour
				break;
			end


		end
		if(n==iters) % si on a parcouru tout le contour sans trouver de pixel blanc
			poly(k,1) = bordAbs;
			poly(k,2) = bordOrd;
			r(1,k) = distanceEucl(x, y, bordAbs, bordOrd);


		end

	end

	% calcul du descripteur de Fourier
	fd = zeros(1,N);
	R(1, 1:M) = fft(r(1,1:M));% calcul de la transformée de Fourier discrète
	tf_r0 = R(1);% valeur de la transformée de Fourier discrète en 0
	fd(1, 1:M) = abs(R(1,1:M))/abs(tf_r0); % calcul des M premiers coefficients du vecteur R(f) / R(0)


end

% calcul du barycentre d'une image img
function m = barycentre(img)
	%liste des points égaux à 1
	[col, row] = find(img>0);
	% somme de toutes les colonnes avec des pixels blancs
	% somme de toutes les lignes avec des pixels blancs
	% puis moyenne
	m = mean([row, col]);   % on inverse row et col pour le barycentre pixel blanc
end

% distance euclidienne entre deux points
function dist = distanceEucl(abs1, ord1, abs2, ord2)
	dist = ((abs2 - abs1).^2 + (ord2 - ord1).^2) .^(0.5);
end

% calcul des coordonnées cartésiennes à partir des coordonnées polaires
function res = cartesianCoord(xi, yi, ro, theta)
	abs = round(xi + ro*cos(theta));
	ord = round(yi + ro*sin(theta));
	res = [abs, ord];
end
