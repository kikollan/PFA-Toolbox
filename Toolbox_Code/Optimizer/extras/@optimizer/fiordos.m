function solver = fiordos(self)

% The first dimin equalities are used to fix some parameters
aux = self.model.F_struc(1:self.dimin,:);

% remove these 
self.model.F_struc(1:self.dimin(1),:) = [];
self.model.K.f = self.model.K.f - self.dimin(1);

% Extract all bounds and move from Ab to ub/lb
self.model =  presolve_bounds_from_modelbounds(self.model,1);   

% Put back a placeholder for fixing the parameters
self.model.F_struc = [aux;self.model.F_struc];
self.model.F_struc(1:self.dimin(1),1)=0; % Now fixed to zero
self.model.K.f = self.model.K.f + self.dimin(1);

% Hack around limitation 
self.model.ub(isinf(self.model.ub))=100;
self.model.lb(isinf(self.model.lb))=-100;

X = EssBox(length(self.model.lb), 'l',self.model.lb, 'u',self.model.ub);
X = SimpleSet(X);
op = OptProb('H',2*full(self.model.Q), 'g',self.model.c, 'X',X, 'Ae',-self.model.F_struc(1:self.model.K.f,2:end), 'be','param'); 

%instantiate solver
s = Solver(op,'approach','dual', 'algoOuter','gm', 'algoInner','fgm'); 
%optionally change settings, e.g.
%-maximum number of iterations
s.setSettings('algoOuter', 'maxit',10000);
s.setSettings('algoInner', 'maxit',9000);
%-gradient-map stopping criterion
s.setSettings('algoOuter', 'stopg',true, 'stopgEps',1e-3); 
s.setSettings('algoInner', 'stopg',true, 'stopgEps',1e-5);
%generate solver code  
s.generateCode('prefix','demo_','forceOverwrite',1);
demo_mex_make();

compiledsolver = @(x)demo_mex(x);
b0 = self.model.F_struc(1:self.model.K.f,1);
B0 = [eye(self.dimin(1));zeros(self.model.K.f-self.dimin(1),self.dimin(1))];
map = self.map;
dimout = self.dimout;
mask = self.mask{1};
solver = @(x)(fiordos_call(compiledsolver,x,B0,b0,mask,map,dimout));
