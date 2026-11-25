import { bootstrapApplication } from '@angular/platform-browser';
import { provideHttpClient } from '@angular/common/http';
import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Capacitor } from '@capacitor/core';
import { provideIonicAngular, IonApp, IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonCard, IonCardContent, IonInput, IonFooter } from '@ionic/angular';
import { GatewayApi, ModuleInfo } from '../../shared/api';
@Component({selector:'app-root',standalone:true,
 imports:[CommonModule,FormsModule,IonApp,IonHeader,IonToolbar,IonTitle,IonContent,IonButton,IonCard,IonCardContent,IonInput,IonFooter],
 templateUrl:'./app.html'})
class App implements OnInit {
 readonly api=inject(GatewayApi);
 readonly tab=signal('overview');
 readonly selected=signal<ModuleInfo|undefined>(undefined);
 address='';
 async ngOnInit(){
  const native=Capacitor.isNativePlatform();
  const fallback=native?(Capacitor.getPlatform()==='android'?'http://10.0.2.2:8080':'http://localhost:8080'):'';
  await this.api.configure(fallback);this.address=this.api.base();
 }
 save(){this.api.setBase(this.address);}
 inspect(module:ModuleInfo){this.selected.set(module);this.api.probe(module);}
}
bootstrapApplication(App,{providers:[provideHttpClient(),provideIonicAngular()]}).catch(console.error);
