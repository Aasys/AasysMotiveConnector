function [MocapData]= GetMocap()   
    global Mocap;
    data = Mocap.GetLastFrameOfData();    
    frameID = data.iFrame;
    frameTime = data.fLatency;
    
    Markers=cell(data.nOtherMarkers,1);
    RigidBodies=cell(data.nRigidBodies,1);
    if(data.nRigidBodies > 0)
        for ii=1:data.nRigidBodies 
            rb = data.RigidBodies(ii);
            rbMarkers = cell(rb.nMarkers ,1);
            for jj=1:rb.nMarkers               
                mm = rb.Markers(jj);                
                rbMarkers{jj,1}=struct('x',-newScale(mm.x),'y',newScale(mm.z),'z', newScale(mm.y));
            end    
            RigidBodies{ii,1}= struct('name',char(data.MarkerSets(ii).MarkerSetName), ...
                    'Markers',{rbMarkers},'qx',{rb.qy},'qy',{rb.qy}, 'qz',{rb.qz}, ...
                    'qw',{rb.qw},'nMarkers',{rb.nMarkers});
        end   
    end
    if (data.nOtherMarkers > 0)
        for jj=1:data.nOtherMarkers
            mm = data.OtherMarkers(jj);
            Markers{jj,1}=struct('x',-newScale(mm.x),'y',newScale(mm.z),'z', newScale(mm.y));
        end    
    end
    MocapData=struct('RigidBodies',{RigidBodies},'nRigidBodies',{size(RigidBodies,1)}, ...
        'Markers',{Markers},'nMarkers',{size(Markers,1)},'FrameID',{frameID},...
        'FrameTime',{frameTime});
end


function newVal = newScale(value)
    %precision to mm
    dVal = double(value);
    dVal = dVal*10000;
    dVal = round(dVal);
    dVal = dVal/10000;
    %scale
    newVal = m2cm(dVal);  
    
end

function [cm] = m2cm(m)   
    cm=m*100;
end
