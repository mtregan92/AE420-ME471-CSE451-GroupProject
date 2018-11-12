% specify gmsh file
% read it in
% get nodes and elements
  % nodes are a map of index to node data
  % elements is a list of elements
% this script knows what kind of problem it is, will call the approprate
% ...function on the particular elements to get the load vector (maybe a
% ...helper for particular types of problems)

% run through routine to get geometry portion of K
% run through routine to get geometry portion of load vector
% apply boundary conditions (to K AND Load Vector)
% invert remaining K an solve for displacements

