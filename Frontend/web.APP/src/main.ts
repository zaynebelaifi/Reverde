import { bootstrapApplication } from '@angular/platform-browser';
import { provideHttpClient } from '@angular/common/http';
import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { GatewayApi, ModuleInfo } from '../../shared/api';
@Component({selector:'app-root',standalone:true,imports:[CommonModule,FormsModule],templateUrl:'./app.html'})
class App implements OnInit {
 readonly api=inject(GatewayApi);
 readonly selected=signal<ModuleInfo>(this.api.modules[2]);
 address='';
 async ngOnInit(){await this.api.configure();this.address=this.api.base();}
 select(module:ModuleInfo){this.selected.set(module);}
 save(){this.api.setBase(this.address);}
}
bootstrapApplication(App,{providers:[provideHttpClient()]}).catch(console.error);
