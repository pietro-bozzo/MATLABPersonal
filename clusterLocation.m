function Channels = clusterLocation(session,opt)
% clusterLocation Assign each cluster to an electrode channel based on max spike amplitude
% Channels and content of FileBase.cluloc file have 3 columns:
% ElecInd CluInd Channel from where cluster comes from 

arguments
  session (1,:) char
  opt.electrodes (:,1) double {mustBeInteger} = []
  opt.overwrite (1,1) {mustBeLogical} = true
end

% recover root for session files
FileBase = strsplit(session,'.');
FileBase = FileBase{1};

% load xml file
Par = LoadPar([FileBase '.xml']);

% assign default value
Electrodes = opt.electrodes;
Overwrite = opt.overwrite;
if isempty(Electrodes)
  Electrodes = 1 : Par.nElecGps;
end

nEl = length(Electrodes);
Channels = [];
 
if isfile([FileBase '.cluloc']) && ~Overwrite
	if FileLength([FileBase '.cluloc'])==0
    	Channels = [];
    else
        Channels = load([FileBase '.cluloc']);
        Channels = Channels(ismember(Channels(:,1),Electrodes),:);
    end
    
    if nargout<1
       figure(212111);clf
       Map = SiliconMap(FileBase,[],[1 1]);
       chstr = num2str(Channels(:,1:2)); 
       [~, ChanInd] = ismember(Channels(:,3),Map.Channels);
       rn = rand(length(ChanInd),1)-0.5;
       jittx(rn>0) = (0.1+rn(rn>0))*0.4*Map.Step(1);
       jittx(rn<0) = (-0.1+rn(rn<0))*0.4*Map.Step(1);
       rn = rand(length(ChanInd),1)-0.5;
       jitty(rn>0) = (0.2+rn(rn>0))*0.5*Map.Step(2);
       jitty(rn<0) = (-0.2+rn(rn<0))*0.5*Map.Step(2);
       
       if FileExists([FileBase '.celllayer'])
           clayer = load([FileBase '.celllayer']);
       else
           clayer = zeros(size(Channels,1),1);
       end
       cols = {'k','b','g','r'};
       for n=0:4
           ci = find(clayer == n);
           if ~isempty(ci)
               h = text(Map.Coord(ChanInd(ci),1)+jittx(ci)', Map.Coord(ChanInd(ci),2)+jitty(ci)', chstr(ci,:));
               set(h,'FontSize',5);
               set(h,'Color',cols{n+1});
           end
       end
       maxc = max(Map.Coord);
       minc = min(Map.Coord);

       xr = (maxc(1)-minc(1));
       yr = (maxc(2)-minc(2));
       axis([minc(1)-0.1*xr maxc(1)+0.1*xr minc(2)-0.1*yr maxc(2)+0.1*yr]);
       set(gca,'YDir','reverse')
       
    end
else
	for n=1:nEl
		
		El = Electrodes(n);
		myChans = Par.ElecGp{El};
		nChannels = length(myChans);
		
		Clu = load([FileBase '.clu.' num2str(El)]);
        Clu = Clu(2:end);
        
        uClu = setdiff(unique(Clu),[0 1]);
        nClu = length(uClu);

        if nClu>0 % not only noise

            %Spk(Channel, Sample, Spike Number)
            %Spk loading takes too much memory!!!
            %FreeMemory
            %Spk = LoadSpk([FileBase '.spk.' num2str(El)],nChannels,32,nSpks);
            %FreeMemory

            % let's use features instead of Spk, lighter to load
            Fet = LoadFet([FileBase '.fet.' num2str(El)]);
            nPCs = (size(Fet,2)-5)/length(Par.ElecGp{El});
           
            for j=1:nClu
                myInd = find(Clu==uClu(j));
                if ~isempty(myInd)
                    %	myMeanSpk = sq(mean(Spk(:,:,myInd),3));
                    %	MaxAmp = max(abs(myMeanSpk),[],2);
                    %	[dummy MaxChan] = max(MaxAmp);
                    myFet = Fet(myInd,:);
                    %myFet = myFet(:,1:Par1.nPCs:end-5);

                    myFet = myFet(:,1:nPCs:end-5);
                    MeanAmp = mean(abs(myFet));
                    [~, MaxChan] = max(MeanAmp);
                    Channels(end+1,:) = [Electrodes(n) uClu(j) myChans(MaxChan)+1]; % NB make channels number go from 1
                end
            end
            clear Fet Clu 
        end
    end

    % save result, adding a header to describe file content
    saveMatrix(Channels,[FileBase '.cluloc'],'electrode','cluster (unit)','channel')
end