function Read_ResultFiles(input_file_extension,num_IC,num_vars,num_meas,...
                          num_params,beta_input,beta_want,lambdini,lambdend,lambdstep)
    close all
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Count how many lambdas there are.
    lambd = lambdini;
    k = 0;
    while lambd < lambdend
        lambd_vect(k+1) = lambd;
        lambd = lambd+lambdstep;
        k = k+1;
    end
    num_lambd = k;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Structure of ground truth model.
    terms_on = [2,3,12,13,17,24,26];
    terms_off = 1:num_params;
    terms_off(terms_on) = [];
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    action = zeros(num_IC*num_lambd,beta_want+1);
    active_terms = zeros(1,num_IC*num_lambd);
    lambd_end = zeros(num_IC*num_lambd,beta_want+1);
    lambd_long_vect = zeros(1,num_IC*num_lambd);
    parameters = zeros(num_IC*num_lambd,num_params);
    
    num_right_model = 0;
    num_terms_off = 0;
    ind_right_model = [];
    ind_subright_model = [];
    ind_notright_model = [];
    lambd_correct = [];    
    loc_right_model = [];
        
    all_actions = [];
    for IC = 1:num_IC   
        IC
        %Open the results file and put it in a matrix A.
        filename = sprintf('../Example_LorenzSynth/outputfiles/D%d_M%d_IC%d_%s.dat', num_vars, num_meas, IC-1,input_file_extension);
        delimiterIn = ' ';
        headerlinesIn = 0;
        B = importdata(filename,delimiterIn,headerlinesIn);
        
        A = [];
        for kk = 1:num_lambd
            ini_B = (beta_input+1)*(kk-1)+1;
            fin_B = (beta_want)+ini_B;
            A = [A; B(ini_B:fin_B,:)];
        end
        
        [lengthA, ~] = size(A);
        
        all_actions = [all_actions; A];
        for ll = 1:num_lambd
            jj_new_ind = IC+num_IC*(ll-1);

            max_beta = lengthA - num_lambd;
            max_beta = max_beta/num_lambd;

            low_lim = (max_beta+1)*(ll-1)+1;
            upp_lim = (max_beta+1)*ll;

            action(jj_new_ind,:) = A(low_lim:upp_lim,3);
            lambd_end(jj_new_ind,:) = A(low_lim:upp_lim,1);
            parameters(jj_new_ind,:) = A(upp_lim,4:end);

            active_terms(jj_new_ind) = sum(parameters(jj_new_ind,:) ~= 0);
            lambd_long_vect(jj_new_ind) = lambd_vect(ll);      

            if (sum(parameters(jj_new_ind,terms_off)) == 0) && (all(parameters(jj_new_ind,terms_on)) == 1)    
                num_right_model = num_right_model + 1;
                ind_right_model = [ind_right_model; IC];
                lambd_correct = [lambd_correct, A(upp_lim,1)];
                loc_right_model = [loc_right_model; jj_new_ind];
            end 
            if (all(parameters(jj_new_ind,terms_on)) == 1) && (sum(parameters(jj_new_ind,terms_off)) ~= 0)
                ind_subright_model = [ind_subright_model; jj_new_ind];
            end 
            if (all(parameters(jj_new_ind,terms_on)) ~= 1) && (sum(parameters(jj_new_ind,terms_off)) ~= 0)
                ind_notright_model = [ind_notright_model; jj_new_ind];
            end            
        end
    end
    
    %%     
    file_parameters = sprintf('parameters_%s.mat',input_file_extension);
    save(file_parameters,'terms_on','terms_off','parameters','action',...
         'lambd_vect','num_lambd','num_IC','ind_subright_model','ind_notright_model',...
         'ind_right_model','loc_right_model','active_terms','lambd_long_vect',...
         'lambdini','lambdend','lambdstep','all_actions','max_beta','num_terms_off',...
         'lambd_end');
end
