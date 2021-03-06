import {
    Component,
    NgZone,
    OnDestroy,
    OnInit,
} from '@angular/core';
import { Router } from '@angular/router';

import { ApiService } from 'jslib/abstractions/api.service';
import { AuthService } from 'jslib/abstractions/auth.service';
import { CryptoService } from 'jslib/abstractions/crypto.service';
import { I18nService } from 'jslib/abstractions/i18n.service';
import { PasswordGenerationService } from 'jslib/abstractions/passwordGeneration.service';
import { PlatformUtilsService } from 'jslib/abstractions/platformUtils.service';
import { StateService } from 'jslib/abstractions/state.service';

import { BroadcasterService } from 'jslib/angular/services/broadcaster.service';

import { RegisterComponent as BaseRegisterComponent } from 'jslib/angular/components/register.component';

const BroadcasterSubscriptionId = 'RegisterComponent';

@Component({
    selector: 'app-register',
    templateUrl: 'register.component.html',
})
export class RegisterComponent extends BaseRegisterComponent implements OnInit, OnDestroy {
    constructor(authService: AuthService, router: Router,
        i18nService: I18nService, cryptoService: CryptoService,
        apiService: ApiService, stateService: StateService,
        platformUtilsService: PlatformUtilsService, passwordGenerationService: PasswordGenerationService,
        private broadcasterService: BroadcasterService, private ngZone: NgZone) {
        super(authService, router, i18nService, cryptoService, apiService, stateService, platformUtilsService,
            passwordGenerationService);
    }

    async ngOnInit() {
        this.broadcasterService.subscribe(BroadcasterSubscriptionId, async (message: any) => {
            this.ngZone.run(() => {
                switch (message.command) {
                    case 'windowHidden':
                        this.onWindowHidden();
                        break;
                    default:
                }
            });
        });
    }

    ngOnDestroy() {
        this.broadcasterService.unsubscribe(BroadcasterSubscriptionId);
    }

    onWindowHidden() {
        this.showPassword = false;
    }
}
